#include "mace/public/mace.h"
#include "mace/public/mace_runtime.h"

#include <fstream>
#include <numeric>
#include <cfloat>

#include <opencv2/opencv.hpp>

using namespace mace;

static bool ReadBinaryFile(std::vector<unsigned char> *data,
    const std::string &filename) {
    std::ifstream ifs(filename, std::ios::in | std::ios::binary);
    if (!ifs.is_open()) {
        return false;
    }
    ifs.seekg(0, ifs.end);
    size_t length = ifs.tellg();
    ifs.seekg(0, ifs.beg);

    data->reserve(length);
    data->insert(data->begin(), std::istreambuf_iterator<char>(ifs),
        std::istreambuf_iterator<char>());
    if (ifs.fail()) {
        return false;
    }
    ifs.close();

    return true;
}

int main(int argc, char* argv[])
{
    std::string base_dir = "F:/workspace/XiaoMI/convert_model/builds/mmcv_model/model";
    std::string pb_file_path = base_dir + "/resnet_v5_stride16_fpn_bigger_without_bn.pb";
    std::string data_file_path = base_dir + "/resnet_v5_stride16_fpn_bigger_without_bn.data";

    DeviceType device_type = DeviceType::CPU;

    // config runtime
    mace::SetOpenMPThreadPolicy(1, static_cast<CPUAffinityPolicy>(0));
    if (device_type == DeviceType::GPU) {
        mace::SetGPUHints(
            static_cast<GPUPerfHint>(3),
            static_cast<GPUPriorityHint>(3));
    }
    const std::string internal_storage_path = "./";
    // Config internal kv storage factory.
    std::shared_ptr<KVStorageFactory> storage_factory(new FileStorageFactory(internal_storage_path));
    SetKVStorageFactory(storage_factory);

    // Define the input and output tensor names.
    std::vector<std::string> input_names = { "data" };
    std::vector<std::string> output_names = { "softmax_score" };

    // Create Engine
    std::shared_ptr<mace::MaceEngine> engine;
    // Create Engine
    MaceStatus create_engine_status;
    std::vector<unsigned char> model_pb_data;
    if (!ReadBinaryFile(&model_pb_data, pb_file_path.c_str())) {
        printf("error load pb\n");
    }
    // Create Engine
    create_engine_status =
        CreateMaceEngineFromProto(model_pb_data,
            data_file_path.c_str(),
            input_names,
            output_names,
            device_type,
            &engine);

    if (create_engine_status != MaceStatus::MACE_SUCCESS) {
        printf("Create engine error, please check the arguments\n");
    }

    const size_t input_count = input_names.size();
    const size_t output_count = output_names.size();

    std::map<std::string, mace::MaceTensor> inputs;
    std::map<std::string, mace::MaceTensor> outputs;
    std::vector<std::vector<int64_t>> input_shapes = { { 1, 256, 144, 3 } };
    std::vector<std::vector<int64_t>> output_shapes = { { 1, 256, 144, 2 } };
    for (size_t i = 0; i < output_count; ++i)
    {
        int64_t output_size = std::accumulate(output_shapes[i].begin(), output_shapes[i].end(), 1, std::multiplies<int64_t>());
        auto buffer_out = std::shared_ptr<float>(new float[output_size], std::default_delete<float[]>());
        outputs[output_names[i]] = mace::MaceTensor(output_shapes[i], buffer_out);
    }

    cv::VideoCapture cap(0);
    while (true)
    {
        cv::Mat frame;
        cap >> frame;

        int64_t t0 = cv::getTickCount();

        cv::Mat input_frame = frame(cv::Rect(0, 0, 270, 480));
        cv::resize(input_frame, input_frame, cv::Size(144, 256));
        cv::Mat process_data;
        input_frame.convertTo(process_data, CV_32F);

        for (size_t i = 0; i < input_count; ++i)
        {
            // Allocate input and output
            int64_t input_size = std::accumulate(input_shapes[i].begin(), input_shapes[i].end(), 1, std::multiplies<int64_t>());
            auto buffer_in = std::shared_ptr<float>((float*)process_data.data, [](float*) {});
            inputs[input_names[i]] = mace::MaceTensor(input_shapes[i], buffer_in);
        }

        engine->Run(inputs, &outputs);

        cv::Mat output_frame(256, 144, CV_32FC2, outputs[output_names[0]].data().get());
        std::vector<cv::Mat> bg_fg;
        cv::split(output_frame, bg_fg);
        bg_fg[1].convertTo(bg_fg[1], CV_8U, 255);

        float cost_time = (cv::getTickCount() - t0) / cv::getTickFrequency() * 1000;
        printf("cost time %f\n", cost_time);

        cv::imshow("input_frame", input_frame);
        cv::imshow("output_frame", bg_fg[1]);
        cv::waitKey(20);
    }

    return 0;
}
