dataTypes = ["CPUndefinedDataType", "CPIntegerDataType", "CPUnsignedIntegerDataType", "CPFloatingPointDataType", "CPComplexFloatingPointDataType"]

types = { "CPUndefinedDataType" : [],
        "CPIntegerDataType" : ["int8_t", "int16_t", "int32_t", "int64_t"],
        "CPUnsignedIntegerDataType" : ["uint8_t", "uint16_t", "uint32_t", "uint64_t"],
        "CPFloatingPointDataType" : ["float", "double"],
        "CPComplexFloatingPointDataType" : [] }

nsnumber_factory = { "int8_t" : "Char",
					"int16_t" : "Short",
					"int32_t" : "Long",
					"int64_t" : "LongLong",
					"uint8_t" : "UnsignedChar",
				   "uint16_t" : "UnsignedShort",
				   "uint32_t" : "UnsignedLong",
				   "uint64_t" : "UnsignedLongLong",
					  "float" : "Float",
					 "double" : "Double"
}

newDataType = "newDataType"
newSampleBytes = "newSampleBytes"
newByteOrder = "newByteOrder"

print "[CPNumericData sampleValue:]"
print ""
print "switch ( self.dataTypeFormat ) {"
for dt in dataTypes:
    print "\tcase %s:" % dt
    if ( len(types[dt]) == 0 ):
        print '\t\t[NSException raise:NSInvalidArgumentException format:@"Unsupported data type (%s)"];' % (dt)
    else:
        print "\t\tswitch ( self.sampleBytes ) {"
        for t in types[dt]:
            print "\t\t\tcase sizeof(%s):" % t
            print "\t\t\t\tresult = [NSNumber numberWith%s:*(%s *)[self samplePointer:sample]];" % (nsnumber_factory[t], t)
            print "\t\t\t\tbreak;"
        print "\t\t}"
    print "\t\tbreak;"
print "}"

print "\n\n"
print "---------------"
print "\n\n"

print "[CPNumericData dataByConvertingToType:sampleBytes:byteOrder:]"
print ""
print "switch ( myDataType.dataTypeFormat ) {"
for dt in dataTypes:
    print "\tcase %s:" % dt
    if ( len(types[dt]) > 0 ):
        print "\t\tswitch ( myDataType.sampleBytes ) {"
        for t in types[dt]:
            print "\t\t\tcase sizeof(%s):" % t
            print "\t\t\t\tswitch ( newDataType.dataTypeFormat ) {"
            for ndt in dataTypes:
                print "\t\t\t\t\tcase %s:" % ndt
                if ( len(types[ndt]) > 0 ):
                    print "\t\t\t\t\t\tswitch ( newDataType.sampleBytes ) {"
                    for nt in types[ndt]:
                        print "\t\t\t\t\t\t\tcase sizeof(%s): { // %s -> %s" % (nt, t, nt)
                        print "\t\t\t\t\t\t\t\t\tconst %s *fromBytes = (%s *)sourceData.bytes;" % (t, t)
                        print "\t\t\t\t\t\t\t\t\tconst %s *lastSample = fromBytes + sampleCount;" % t
                        print "\t\t\t\t\t\t\t\t\t%s *toBytes = (%s *)((NSMutableData *)newData).mutableBytes;" % (nt, nt)
                        print "\t\t\t\t\t\t\t\t\twhile ( fromBytes < lastSample ) *toBytes++ = (%s)*fromBytes++;" % nt
                        print "\t\t\t\t\t\t\t\t}"
                        print "\t\t\t\t\t\t\t\tbreak;"
                    print "\t\t\t\t\t\t}"
                print "\t\t\t\t\t\tbreak;"
            print "\t\t\t\t}"
            print "\t\t\t\tbreak;"
        print "\t\t}"
    print "\t\tbreak;"
print "}"
