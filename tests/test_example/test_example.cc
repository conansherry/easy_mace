#include "mace/public/mace.h"
#include "mace/public/mace_runtime.h"
#include "mace/utils/env_time.h"

#include <fstream>
#include <numeric>
#include <cfloat>

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
    std::string pb_file_path = base_dir + "/hand_pose_21pt.pb";
    std::string data_file_path = base_dir + "/hand_pose_21pt.data";

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
    //std::vector<std::string> output_names = { "upsampling0" };
    std::vector<std::string> output_names = { "P2_aggregate" };

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
    //std::vector<std::vector<int64_t>> output_shapes = { { 1, 32, 18, 64 } };
    std::vector<std::vector<int64_t>> output_shapes = { { 1, 32, 18, 22 } };
    for (size_t i = 0; i < input_count; ++i)
    {
        // Allocate input and output
        int64_t input_size = std::accumulate(input_shapes[i].begin(), input_shapes[i].end(), 1, std::multiplies<int64_t>());
        auto buffer_in = std::shared_ptr<float>(new float[input_size], std::default_delete<float[]>());
        for (int j = 0; j < input_size; ++j)
        {
            buffer_in.get()[j] = 128.f;
        }
        inputs[input_names[i]] = mace::MaceTensor(input_shapes[i], buffer_in);
    }

    for (size_t i = 0; i < output_count; ++i)
    {
        int64_t output_size = std::accumulate(output_shapes[i].begin(), output_shapes[i].end(), 1, std::multiplies<int64_t>());
        auto buffer_out = std::shared_ptr<float>(new float[output_size], std::default_delete<float[]>());
        outputs[output_names[i]] = mace::MaceTensor(output_shapes[i], buffer_out);
    }

    std::string test_name = "mace mobilenet";
    double total_time = 0;
    int total_count = 0;
    float max_time = FLT_MIN;
    float min_time = FLT_MAX;
    const int loop_count = 20;

    for (int i = 0; i < loop_count + 2; i++)
    {
        int64_t t0 = NowMicros();

        engine->Run(inputs, &outputs);

        for (auto &kv : outputs)
        {
            printf("--> %f\n", kv.second.data().get()[0]);
            //std::ofstream fout("F:/workspace/XiaoMI/tmp/test_conv/hand_mace.txt");
            //for (int j = 0; j < 32 * 18 * 22; j++)
            //{
            //    fout << kv.second.data().get()[j] << " " << std::endl;
            //}
            //fout.close();
        }

        if (i >= 2)
        {
            float cost_time = (NowMicros() - t0) / TickFerquency() * 1000;
            printf("mace name = %s, cost = %f\n", test_name.c_str(), cost_time);
            if (min_time > cost_time)
                min_time = cost_time;
            if (max_time < cost_time)
                max_time = cost_time;
            total_time += cost_time;
            total_count++;
        }

        //system("pause");
    }

    printf("mace name = %s, min = %f, max = %f, avg = %f\n", test_name.c_str(), min_time, max_time, total_time / total_count);

    return 0;
}
