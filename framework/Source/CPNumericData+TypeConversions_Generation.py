dataTypes = ["CPUndefinedDataType", "CPIntegerDataType", "CPUnsignedIntegerDataType", "CPFloatingPointDataType", "CPComplexFloatingPointDataType"]

types = { "CPUndefinedDataType" : [],
        "CPIntegerDataType" : ["char", "short", "NSInteger"], #, "long"],
        "CPUnsignedIntegerDataType" : ["unsigned char", "unsigned short", "NSUInteger"], #, "unsigned long"],
        "CPFloatingPointDataType" : ["float", "double"],
        "CPComplexFloatingPointDataType" : [] }

nsnumber_factory = { "char" : "Char",
                    "short" : "Short",
                    "NSInteger" : "Integer",
                    "unsigned char" : "UnsignedChar",
                    "unsigned short" : "UnsignedShort",
                    "NSUInteger" : "UnsignedInteger",
                    "float" : "Float",
                    "double" : "Double"
}

newDataType = "newDataType"
newSampleBytes = "newSampleBytes"
newByteOrder = "newByteOrder"

print "[CPNumericData dataByConvertingToType:sampleBytes:byteOrder:]"
print ""
print "NSData *result = nil;"
print "switch( [self dataTypeFormat] ) {"
for dt in dataTypes:
    print "\tcase %s:" % dt
    if ( len(types[dt]) == 0 ):
        print '\t\t[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (%s)"];' % (dt)
    else:
        print "\t\tswitch( [self sampleBytes] ) {"
        for t in types[dt]:
            print "\t\t\tcase sizeof(%s):" % t
            print "\t\t\t\tswitch( %s ) {" % newDataType
            for ndt in dataTypes:
                print "\t\t\t\t\tcase %s:" % ndt
                print "\t\t\t\t\t\tswitch( %s ) {" % newSampleBytes
                for nt in types[dt]:
                    print "\t\t\t\t\t\t\tcase sizeof(%s):" % nt
                    print "\t\t\t\t\t\t\t\tresult = coreplot::convert_numeric_data_type<%s, %s>(self.data, [self byteOrder], %s);" % (t, nt, newByteOrder)
                    print "\t\t\t\t\t\t\t\tbreak;"
                print "\t\t\t\t\t\t}"
                print "\t\t\t\t\t\tbreak;"
            print "\t\t\t\t}"
            print "\t\t\t\tbreak;"
        print "\t\t}"
    print '\t\tbreak;'
print "}"
  
  
print "---------------"
print ""
print "[CPNumericData sampleValue:]"
print ""
print "switch( [self dataTypeFormat] ) {"
for dt in dataTypes:
    print "\tcase %s:" % dt
    if( len(types[dt]) == 0 ):
        print '\t\t[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (%s)"];' % (dt)
    else:
        print "\t\tswitch( [self sampleBytes] ) {"
        for t in types[dt]:
            print "\t\t\tcase sizeof(%s):" % t
            print "\t\t\t\tresult = [NSNumber numberWith%s:*(%s *)[self samplePointer:sample]];" % (nsnumber_factory[t], t)
            print "\t\t\t\tbreak;"
        print "\t\t}"
    print "\t\tbreak;"
print "}"