#!/bin/sh

# STAMP is set externally

inputpath="$1"
outputdir="$2"
indexnumber=`basename "${inputpath}" '.ppm'`
#echo "indexnumber = ${indexnumber}"
# allow four 4 digit position and sign as well as decimal point and fraction to fit in 16 characters
# starts at 1001 and increments by 1 but nominally 0.33 mm
zpositionunsigned=`echo "scale=10; ((${indexnumber} - 1001)) / 3 + 1001" | bc -l`
#echo "zpositionunsigned = ${zpositionunsigned}"
instancenumber=`echo "${indexnumber}"`
#echo "instancenumber = ${instancenumber}"

echo "Doing ${inputpath}"

pnmtodc \
        -stamp ${STAMP} -nodisclaimer \
        -r Modality "XC" -r SOPClassUID "1.2.840.10008.5.1.4.1.1.7" -r ImageType "DERIVED\PRIMARY" -r LossyImageCompression "00" -r AcquisitionContextSequence " " \
        -r BodyPartExamined WHOLEBODY -d NumberOfFrames \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -r StudyID "VHP-F-FC" -r StudyDate "19940225" -r StudyTime "000000" \
        -r StudyDescription "Cryomacrotome anatomic images" \
        -r SeriesNumber 2 \
        -r SeriesDescription "70mm film - digitized" \
        -r ConversionType "DF" \
        -r PixelSpacing '.144\.144' -r SpacingBetweenSlices ".3333333333" -r SliceLocation "${zpositionunsigned}" \
        -r FrameOfReferenceUID "2.25.105476862367628410477813254715804995599" \
        -r PositionReferenceIndicator "VERTEX_IS_1001" \
        -r ImagePositionPatient "0\0\-${zpositionunsigned}" \
        -r ImageOrientationPatient "1\0\0\0\-1\0" \
        -r InstanceNumber "${instancenumber}" \
        -r Manufacturer "Rolleiflex, Eastman Kodak" -r ManufacturerModelName "6008 70-mm, Ektachrome 64T" \
        -r LensMake "Carl Zeiss" -r LensModel "Makro-planar" -r LensSpecification "120\120\4\4" -r FocalLength 120 -r FNumber "8" -r FilterType "POLARIZING\85B" \
        -r DerivationDescription "Converted by libtiff-tools tifftopnm and dicom3tools pnmtodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "${inputpath}" \
               "${inputpath}" \
               "${outputdir}/${indexnumber}.dcm"
