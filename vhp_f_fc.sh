#!/bin/sh

# STAMP is set externally

inputpath="$1"
outputdir="$2"
indexnumberwithsuffix=`basename "${inputpath}" '.raw' | sed -e 's/^avf//'`
#echo "indexnumberwithsuffix = ${indexnumberwithsuffix}"
# allow four 4 digit position and sign as well as decimal point and fraction to fit in 16 characters
zpositionunsigned=`echo "${indexnumberwithsuffix}" | sed -e 's/a$/.0000000000/' | sed -e 's/b$/.3333333333/' | sed -e 's/c$/.6666666667/'`
#echo "zpositionunsigned = ${zpositionunsigned}"
instancenumber=`echo "${indexnumberwithsuffix}" | sed -e 's/a$/0/' | sed -e 's/b$/1/' | sed -e 's/c$/2/'`
#echo "instancenumber = ${instancenumber}"

rawtodc -rows 1216 -columns 2048 -bits 8 -samples 3 -color-by-plane \
        -stamp ${STAMP} -nodisclaimer \
        -r Modality "XC" -r SOPClassUID "1.2.840.10008.5.1.4.1.1.7" -r ImageType "ORIGINAL\PRIMARY" -r LossyImageCompression "00" -r AcquisitionContextSequence " " \
        -r BodyPartExamined WHOLEBODY -d NumberOfFrames \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -r StudyID "VHP-F-FC" -r StudyDate " " -r StudyTime " " \
        -r StudyDescription "Cryomacrotome anatomic images" \
        -r SeriesNumber 1 \
        -r SeriesDescription "Fullcolor - direct digital" \
        -r ConversionType "DI" \
        -r PixelSpacing '.3333333333\.3333333333' -r SpacingBetweenSlices ".3333333333" -r SliceLocation "${zpositionunsigned}" \
        -r FrameOfReferenceUID "2.25.71837758865959743061797451339751164512" \
        -r PositionReferenceIndicator "VERTEX_IS_1001" \
        -r ImagePositionPatient "0\0\-${zpositionunsigned}" \
        -r ImageOrientationPatient "1\0\0\0\-1\0" \
        -r InstanceNumber "${instancenumber}" \
        -r Manufacturer "Leaf, Hasselblad" -r ManufacturerModelName "Digital Camera Back I, 553 ELX" -r DetectorType "CCD" \
        -r LensMake "Carl Zeiss" -r LensModel "Distagon" -r LensSpecification "50\50\4\4" -r FocalLength 50 -r FNumber "6.8" -r FilterType "POLARIZING" \
        -r DerivationDescription "Converted by dicom3tools rawtodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "${inputpath}" \
               "${inputpath}" \
               "${outputdir}/avf${indexnumberwithsuffix}.dcm"
