module candle.Version;

import candle.all;

struct Version {
    static const int majorVersion = 0;
    static const int minorVersion = 1;
    static string stringOf = format("%s.%s", majorVersion, minorVersion);
}

/*

0.1 - Initial version

*/
