module candle.errors.EError;

import candle.all;

enum EError {
    SNF,        // symbol not found
    SNV,        // symbol not visible

    CIRCDEP,    // circular dependency
    CTNT,       // comparing type with non-type
    PANPUDT,    // public alias to non-public UDT

}
