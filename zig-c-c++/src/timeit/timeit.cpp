#include <chrono>

#ifdef __cplusplus
extern "C"
{
#endif

#include "timeit.h"

    float time_it(void (*f)(void))
    {
        auto start = std::chrono::high_resolution_clock::now();
        f();
        auto end = std::chrono::high_resolution_clock::now();
        return std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() * 1e-3;
    }

#ifdef __cplusplus
}
#endif