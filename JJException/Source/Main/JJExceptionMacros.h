//
//  JJExceptionMacros.h
//  JJException
//
//  Created by Kealdish on 2019/2/26.
//  Copyright © 2019 Jezz. All rights reserved.
//

#ifndef JJExceptionMacros_h
#define JJExceptionMacros_h

/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 *******************************************************************************
 Example:
 JJSYNTH_DUMMY_CLASS(NSObject_DeallocBlock)
 */
#ifndef JJSYNTH_DUMMY_CLASS
#define JJSYNTH_DUMMY_CLASS(_name_) \
@interface JJSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation JJSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif

#endif /* JJExceptionMacros_h */
