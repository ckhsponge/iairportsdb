//
//  IADBConstants.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#ifndef airportsdb_IADBConstants_h
#define airportsdb_IADBConstants_h

#define METERS_PER_NM (1852.0)
#define METERS_PER_KTS (METERS_PER_NM/3600.0)
#define NM(x) (round(x/(METERS_PER_NM)))
#define NM_PER_LATITUDE (60.0)

#define LATITUDE_DEGREES_FROM_NM(nm) ((nm)/NM_PER_LATITUDE)
#define LONGITUDE_DEGREES_FROM_NM(nm,latitude) ((nm)/(NM_PER_LATITUDE*cos((latitude)*M_PI/180.0)))

#define FEET_PER_METER (3.28084)

static inline double withinZeroTo360(double degrees) {
    return (degrees - (360.0 * floor(degrees/360.0)));
}

static inline double within180To180(double degrees) {
    degrees = withinZeroTo360(degrees);
    if (degrees > 180.0) {
        degrees -= 360.0;
    }
    return degrees;
}

#endif
