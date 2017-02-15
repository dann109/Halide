#ifndef HALIDE_INTERNAL_AUTO_SCHEDULE_H
#define HALIDE_INTERNAL_AUTO_SCHEDULE_H

/** \file
 *
 * Defines the method that does automatic scheduling of Funcs within a pipeline.
 */

#include "Function.h"
#include "Target.h"

namespace Halide {

namespace Internal {

struct MachineParams {
    uint32_t parallelism;
    uint32_t vec_len;
    uint32_t last_level_cache_size;
    /** 'balance' indicates how much more expensive is the cost of a load
     * compared the cost of an arithmetic operation at last level of cache. */
    uint32_t balance;
};

/** Generate schedules for Funcs within a pipeline. The Funcs should not already
 * have specializations or schedules as the current auto-scheduler does not take
 * into account user-defined schedules or specializations. This applies the
 * schedules and returns a string representation of the schedules. The target
 * architecture is specified by 'target'. */
EXPORT std::string generate_schedules(const std::vector<Function> &outputs,
                                      const Target &target,
                                      const MachineParams &arch_params);

}
}

#endif
