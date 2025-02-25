#include <cuda.h>
#include <cuda_runtime.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/scan.h>
#include <thrust/sort.h>
#include "common.h"
#include "thrust.h"

namespace StreamCompaction {
    namespace Thrust {
        using StreamCompaction::Common::PerformanceTimer;
        PerformanceTimer& timer()
        {
            static PerformanceTimer timer;
            return timer;
        }
        /**
         * Performs prefix-sum (aka scan) on idata, storing the result into odata.
         */
        void scan(int n, int *odata, const int *idata) {
            
            // TODO use `thrust::exclusive_scan`
            // example: for device_vectors dv_in and dv_out:
            // thrust::exclusive_scan(dv_in.begin(), dv_in.end(), dv_out.begin());
            thrust::host_vector<int> thrust_host_data(idata, idata + n);
            thrust::device_vector<int> thrust_dev_idata = thrust_host_data;
            thrust::device_vector<int> thrust_dev_odata(n);
            
            timer().startGpuTimer();
            thrust::exclusive_scan(thrust_dev_idata.begin(), thrust_dev_idata.end(), thrust_dev_odata.begin());
            timer().endGpuTimer();
            
            
            thrust::copy(thrust_dev_odata.begin(), thrust_dev_odata.end(), odata);            
        }

        void sort(int n, int* odata, const int* idata) {
            thrust::host_vector<int> thrust_host_data(idata, idata + n);
            thrust::device_vector<int> thrust_dev_data = thrust_host_data;

            timer().startGpuTimer();
            thrust::sort(thrust_dev_data.begin(), thrust_dev_data.end());
            timer().endGpuTimer();

            thrust::copy(thrust_dev_data.begin(), thrust_dev_data.end(), odata);
        }
    }
}
