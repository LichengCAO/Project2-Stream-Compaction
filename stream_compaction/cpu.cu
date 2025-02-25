#include <cstdio>
#include "cpu.h"

#include "common.h"

namespace StreamCompaction {
    namespace CPU {
        using StreamCompaction::Common::PerformanceTimer;
        PerformanceTimer& timer()
        {
            static PerformanceTimer timer;
            return timer;
        }

        /**
         * CPU scan (prefix sum).
         * For performance analysis, this is supposed to be a simple for loop.
         * (Optional) For better understanding before starting moving to GPU, you can simulate your GPU scan in this function first.
         */
        void scan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            // TODO
            if (n > 0)odata[0] = 0;
            for (int i = 1;i < n;++i) {
                odata[i] = odata[i-1] + idata[i - 1];
            }
            timer().endCpuTimer();
        }

        void sort(int n, int* odata, const int* idata) {
            
            memcpy(odata, idata, sizeof(int) * n);

            timer().startCpuTimer();
            std::sort(odata, odata + n);
            timer().endCpuTimer();
        }

        /**
         * CPU stream compaction without using the scan function.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithoutScan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            // TODO
            int ans = 0;
            for (int i = 0;i < n;++i) {
                if (idata[i] != 0) {
                    odata[ans++] = idata[i];
                }
            }
            timer().endCpuTimer();
            return ans;
        }

        /**
         * CPU stream compaction using scan and scatter, like the parallel version.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithScan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            // TODO
            int* cnt = new int[n];
            for (int i = 0;i < n;++i) {
                cnt[i] = idata[i] == 0 ? 0 : 1;
            }
            
            //scan(n, odata, cnt);
            if (n > 0)odata[0] = 0;
            for (int i = 1;i < n;++i) {
                odata[i] = odata[i - 1] + cnt[i - 1];
            }

            int numIdx = 0;
            for (int i = 0;i < n;++i) {
                if (idata[i] != 0) {
                    numIdx = odata[i];
                    odata[numIdx] = idata[i];
                }
            }
            delete[] cnt;
            timer().endCpuTimer();
            return (numIdx+1);
        }
    }
}
