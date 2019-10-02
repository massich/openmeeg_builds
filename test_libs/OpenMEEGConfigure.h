#pragma once

/* Define to 1 if your processor stores words with the most significant byte
   first (like Motorola and SPARC, unlike Intel and VAX). */

static const char version[] = "2.4.9999";

#ifdef USE_OMP
    #define STATIC_OMP
    #if defined _OPENMP
        #if _OPENMP>=200805
            #define OPENMP_3_0
        #endif
    #endif
#else
    #define STATIC_OMP static
#endif
