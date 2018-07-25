#include <common.h>

__kernel void depthwise_deconv2d(KERNEL_ERROR_PARAMS
                        GLOBAL_WORK_GROUP_SIZE_DIM3
                        __read_only image2d_t input,
                        __read_only image2d_t weights,
#ifdef BIAS
                        __read_only image2d_t bias,
#endif
                        __write_only image2d_t output,
                        __private const float relux_max_limit,
                        __private const int in_height,
                        __private const int in_width,
                        __private const int in_channels,
                        __private const int out_height,
                        __private const int out_width,
                        __private const int out_channel,
                        __private const int stride,
                        __private const float stride_r,
                        __private const int align_h,
                        __private const int align_w,
                        __private const int padding_h,
                        __private const int padding_w,
                        __private const int kernel_h,
                        __private const int kernel_w,
                        __private const int kernel_size,
                        __private const int in_channel_blocks,
                        __private const int out_channel_blocks)
{
  const int c = get_global_id(0);
  const int w_id = get_global_id(1);
  const int hb = get_global_id(2);

#ifndef NON_UNIFORM_WORK_GROUP
  if (c >= global_size_dim0 || w_id >= global_size_dim1
      || hb >= global_size_dim2) {
    return;
  }
#endif

#ifdef BIAS
  DATA_TYPE4 out0 = READ_IMAGET(bias, SAMPLER, (int2)(c, 0));
#else
  DATA_TYPE4 out0 = 0;
#endif

  const int w = w_id;
  const int b = hb / out_height;
  const int h = hb - mul24(b, out_height);
  if (w < out_width) {
    int start_x = max(0.f, ceil((float)(w - (kernel_w - 1 - padding_w)) * stride_r));
    int start_y = max(0.f, ceil((float)(h - (kernel_h - 1 - padding_h)) * stride_r));
    int f_start_x = mad24(start_x, stride, (kernel_w - 1 - padding_w)) - w;
    int f_start_y = mad24(start_y, stride, (kernel_h - 1 - padding_h)) - h;
    
    f_start_x = kernel_w - 1 - f_start_x;
    f_start_y = kernel_h - 1 - f_start_y;

    int2 in_pos;
    int f_pos_x0, f_pos_y;
    DATA_TYPE4 in0, in1, in2, in3, in4;
    DATA_TYPE4 weight0, weight1, weight2, weight3;
    int idx_w0, idx_w1, idx_w2, idx_w3, idx_w4;
    int index_x, index_y;
    int ic = c;
    f_pos_x0 = 0;
    for (int f_y = f_start_y, idx_h = start_y ; f_y >= 0; f_y -= stride, ++idx_h) {
      index_y = mad24(b, in_height, idx_h);
      in_pos.y = select(index_y, -1, idx_h < 0 || idx_h >= in_height);
      for (int f_x = f_start_x, idx_w = start_x; f_x >= 0; f_x -= stride, ++idx_w) {
        f_pos_y = mad24(f_y, kernel_w, f_x);
        f_pos_y = mad24(c, kernel_size, f_pos_y);
        weight0 = READ_IMAGET(weights, SAMPLER, (int2)(f_pos_x0, f_pos_y));

        idx_w0 = idx_w;

#define READ_INPUT(i)                                                         \
        index_x = mad24(ic, in_width, idx_w##i);                            \
        in_pos.x =                                                          \
          select(index_x, -1, idx_w##i < 0 || idx_w##i >= in_width);        \
        in##i = READ_IMAGET(input, SAMPLER, in_pos);

        READ_INPUT(0);
#undef READ_INPUT

#define CALC_OUTPUT(i)                                                          \
        out##i.x = mad(in##i.x, weight0.x, out##i.x);                         \
        out##i.y = mad(in##i.y, weight0.y, out##i.y);                         \
        out##i.z = mad(in##i.z, weight0.z, out##i.z);                         \
        out##i.w = mad(in##i.w, weight0.w, out##i.w);

          CALC_OUTPUT(0);
#undef CALC_OUTPUT
      }
    }

#if defined(USE_RELU) || defined(USE_RELUX) || defined(USE_TANH) || defined(USE_SIGMOID)
    out0 = do_activation(out0, relux_max_limit);
#endif

    int2 out_pos;
    out_pos.y = hb;

    int ow = w;
    if (ow >= out_width) return;
    out_pos.x = mad24(c, out_width, ow);
    WRITE_IMAGET(output, out_pos, out0);
  }
}