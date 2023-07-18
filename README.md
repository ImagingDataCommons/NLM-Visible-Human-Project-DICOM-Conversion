# Overview

The [Visible Human Project](https://www.nlm.nih.gov/research/visible/visible_human.html) consists of a publicly-available set of cross-sectional cryosection, CT, and MRI images of human cadavers, originally supplied in proprietary vendor-specific and raw image formats. Since a [license is no longer required](https://www.nlm.nih.gov/databases/download/terms_and_conditions.html) to access and re-distribute these images, they have been converted to DICOM for inclusion in IDC. IDC acknowledges the NLM as the source of these images, and has endeavoured to assure that the most [recently available files from NLM](https://www.nlm.nih.gov/databases/download/vhp.html) have been used in the conversion.

A technical report is available that describes in detail the manner in which the male cadaver images were obtained:

Spitzer V, Ackerman MJ, Scherzinger AL, Whitlock D. The Visible Human Male: A Technical Report. J Am Med Inf Assoc. 1996 Mar 1;3(2):118–30. [doi:10.1136/jamia.1996.96236280](http://dx.doi.org/10.1136/jamia.1996.96236280).

This report was used to ascertain the characteristics of the available proprietary and raw format images, as well as to supply additional metadata that was added during the conversion process.

# Limitations of the source data

The goal of the DICOM conversion process is to produce a complete replica of the original images to the extent that they have been successfully preserved in the NLM archive. For this reason, any flaws in the original data, some of which are documented in the referenced technical report (such as missing slices or truncated files), persist in the converted data. There has been no attempt to improve the supplied data, whether it be by interpolation to add missing information, registration in the cases where cryosections have not already been registered, or lossy compression to reduce the relatively large file sizes.

Some slices may be missing from a complete 3D volume. From the Technical Report:
>*"Anatomic slices missing due to kerf loss were indicated by the use of empty files as place holders."*

Also:

>*"Partial slices are included in the 42-bit “raw” images that were eliminated from the “processed” 24-bit images due to their having little anatomic content or because the tissue was permeated with the blue gelatin. These partial slices can be attributed to the opposing cut surfaces of the second and third blocks’ not being perfectly parallel, or from the inferior surfaces of the second through fourth blocks’ not being perfectly flat. Other losses include actual loss of tissue during the cutting of the last few slices of a block."*.
>However, in the 70mm digitized film data some slices fail to convert since are actually zero length in the source, rather than being replacement slices.

Some radiological (plain projection X-Ray) images of the Male are present in the original data, but since the format of these is not specified in the technical report and does not seem straightforward to reverse engineer, the images in the Male-Images/radiological/xray14 and xray8 folders have not been converted.

# Conversion process for proprietary CT and MR images

The CT and MR images were obtained on GE scanners, and are encoded in the proprietary [Genesis format](http://www.dclunie.com/medical-image-faq/html/part4.html#Signa5X). Existing conversion tools ([dicom3tools](http://www.dclunie.com/dicom3tools.html)) were used to convert these to DICOM, adding relevant metadata during the process.

An attempt is made to populate the SliceLocation with values from the original filename that correspond to the cryosections, since from the technical report:
>*"When the alignment of CT scans and anatomic slices was finalized and the anatomic kerf spaces were determined, the anatomic and CT slices were renumbered to reflect the correspondence. Numbering was started at 1,001 and proceeded to 2,878. Anatomic slices missing due to kerf loss were indicated by the use of empty files as place holders. CT slices were numbered as c_vmXXXX, and the anatomic slices were numbered as a_vmXXXX. The resultant digital data set consisted of anatomic slices in 24-bit “raw” file format and CT slices numbered correspondingly, still containing their original General Electric format headers."*

## CT Images

To generate novel UIDs that are consistent across Series and Studies, a STAMP environment variable is set:

```
#setenv STAMP 1672334394.26545
STAMP=1672334394.26545; export STAMP
```

The following Bourne shell commands were used to convert the normal and frozen male CT images, retaining the numeric SliceLocation information embedded in the file name (e.g., "c_vm1260.fro"), preserving the original file name in a private data element, removing the gantry-specific position and orientation data elements from the old ACR-NEMA standard, and manually specifying a soft tissue window:

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/normalCT -name '*.fre' | xargs -L1 -I% basename % '.fre' | sed -e 's/^c_vm//' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r WindowCenter 40 -r WindowWidth 400 -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -r StudyDescription Normal \
        -r SliceLocation "%" \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/normalCT/c_vm%.fre" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/normalCT/c_vm%.fre \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/normalCT/c_vm%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/frozenCT -name '*.fro' | xargs -L1 -I% basename % '.fro' | sed -e 's/^c_vm//' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r WindowCenter 40 -r WindowWidth 400 -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -r StudyDescription Frozen \
        -r SliceLocation "%" \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/frozenCT/c_vm%.fro" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/frozenCT/c_vm%.fro \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/scoutCT -name '*.fro' | xargs -L1 -I% basename % '.fro' | sed -e 's/^c_vm//' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r WindowCenter 200 -r WindowWidth 1800 -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -r StudyDescription Frozen \
         -r RescaleType US -d RotationDirection \
        -r SliceLocation "%" \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/scoutCT/c_vm%.fro" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/scoutCT/c_vm%.fro \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/scoutCT/c_vm%.dcm
```

Since one of the slices had been lost and was replaced with a duplicate slice (#254 in c_vm1259 and c_vm1260), the duplicate SOPInstance that resulted from the normal conversion process needed to be manually corrected:

```
dcentfy ...
Error - Duplicate SOPInstanceUID - 1.3.6.1.4.1.5962.1.1.32.4.254.1672334394.26545 within Series for file <vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1259.dcm> versus <vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1260.dcm>
dckey -k SOPInstanceUID vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1260.dcm
1.3.6.1.4.1.5962.1.1.32.4.254.1672334394.26545
mv vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1260.dcm /tmp/crap.dcm
dccp \
	-nodisclaimer -r SOPInstanceUID "1.3.6.1.4.1.5962.1.1.32.4.254999.${STAMP}" \
	/tmp/crap.dcm \
	vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1260.dcm
dcdiff \
	/tmp/crap.dcm \
        vhm-data/dst/Visible-Human/Male-Images/radiological/frozenCT/c_vm1260.dcm
rm /tmp/crap.dcm
```

Female CT images were converted similarly:

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/normalCT -name '*.fre' | xargs -L1 -I% basename % '.fre' | sed -e 's/^c_vf//' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r WindowCenter 40 -r WindowWidth 400 -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -d OperatorsName -r StudyDescription Normal \
        -r SliceLocation "%" \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Female-Images/radiological/normalCT/c_vf%.fre" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/normalCT/c_vf%.fre \
                                           	            vhm-data/dst/Visible-Human/Female-Images/radiological/normalCT/c_vf%.dcm
```

## MR Images

MR images were converted similarly, with AcquisitionContrast of T1, T2 and PD being specified manually based on the file name (rather than SeriesDescription since in the latter, "T2" is used for both slices of dual echo (PD and T2)), and incorrect window and undesirable rescale data elements removed.

For the male:

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri -name '*.t1' | xargs -L1 -I% basename % '.t1' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast T1 \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/mri/%.t1" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri/%.t1 \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/mri/t1/%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri -name '*.t2' | xargs -L1 -I% basename % '.t2' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast T2 \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/mri/%.t2" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri/%.t2 \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/mri/t2/%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri -name '*.pd' | xargs -L1 -I% basename % '.pd' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast PROTON_DENSITY \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/radiological/mri/%.pd" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/radiological/mri/%.pd \
                                                            vhm-data/dst/Visible-Human/Male-Images/radiological/mri/pd/%.dcm
```

And for the female:
```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri -name '*.t1' | xargs -L1 -I% basename % '.t1' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast T1 \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Female-Images/radiological/mri/%.t1" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri/%.t1 \
                                                            vhm-data/dst/Visible-Human/Female-Images/radiological/mri/t1/%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri -name '*.t2' | xargs -L1 -I% basename % '.t2' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast T2 \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Female-Images/radiological/mri/%.t2" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri/%.t2 \
                                                            vhm-data/dst/Visible-Human/Female-Images/radiological/mri/t2/%.dcm
```

```
find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri -name '*.pd' | xargs -L1 -I% basename % '.pd' | xargs -L1 -I% \
    gentodc -stamp ${STAMP} -nodisclaimer -r BodyPartExamined WHOLEBODY -d ImagePosition -d ImageOrientation -d PatientWeight \
        -r PatientID 'VHP-F' -r PatientName 'VisibleHumanProject^Female' \
        -d OperatorsName -d WindowWidth -d WindowCenter -d RescaleSlope -d RescaleIntercept -d RescaleType \
        -r AcquisitionContrast PROTON_DENSITY \
        -r DerivationDescription "Converted by dicom3tools gentodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Female-Images/radiological/mri/%.pd" \
                vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/radiological/mri/%.pd \
                                                            vhm-data/dst/Visible-Human/Female-Images/radiological/mri/pd/%.dcm
```

## Color cryosection images
The cryosection images were mostly supplied in a raw format, described by an accompanying README file that described the frame size, the pixel size (in-plane and between slices) (which was used instead of what was described in the technical report). The slice interval was encoded in SpacingBetweenSlices but not SliceThickness (since latter is theoretically zero, since these are photographs not slices). The "fullbody" directory was used as the source, since it contains all the images.

The Secondary Capture Image Storage SOP Class was used, extended with ImagePlaneModule and FrameOfReferenceModule data elements in case downstream applications can use them to orient and position images properly and use them as a 3D volume. The encoded mages are LA+, position from file name is F+ (DICOM PCS is LPH+), and from the technical report, the number in file name is in 1mm increments.

A unique value was created for the FrameOfReferenceUID to be used:
```
java -cp . com.pixelmed.utils.UUIDBasedOID
2.25.33318953395384912699580822170414899294
```

Some VLPhotographicEquipmentModule and VLPhotographicAcquisitionModule data elements were added to describe features noted in the technical report. The VL Photographic Image Storage SOP class was not used since it does not allow a Planar Configuration of 1, which is the non-interleaved color plane encoding used in the supplied raw images.

The StudyDate was chosen based on information in the technical report, which states that:
>*"The 1-mm cutting of the Visible Human Male began on February 25, 1994, at the highest level of the first block, just inferior to the knees. Cutting of the first block (the legs and feet) was completed on March 21, 1994. Cutting of the second block (the thighs) was finished on April 4, 1994. Cutting of the third block (the abdomen and pelvis) was finished on April 30, 1994. Cutting of the fourth block (the head, neck, and thorax) was finished on May 19, 1994."*

```
# README FILE - Male Fullcolor
# Anatomical Area:  HEAD, THORAX, ABDOMEN, PELVIS, THIGHS, LEGS, FULLBODY
# Type image:  COLOR BIT MAPPED
# Frame size:  2048,1216      
# Pixel size: .33mm,.33mm,1mm
# Image format:  RGB 24 BIT NON INTERLEAVED, COMPRESSED.
# Header size: NONE      
# Coordinate offset:  NONE,NONE

find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/Fullcolor/fullbody -name '*.raw' | xargs -I% basename '%' '.raw' | sed -e 's/^a_vm//' | xargs -I% \
    rawtodc -rows 1216 -columns 2048 -bits 8 -samples 3 -color-by-plane \
        -stamp ${STAMP} -nodisclaimer \
        -r Modality "XC" -r SOPClassUID "1.2.840.10008.5.1.4.1.1.7" -r ImageType "ORIGINAL\PRIMARY" -r LossyImageCompression "00" -r AcquisitionContextSequence " " \
        -r BodyPartExamined WHOLEBODY -d NumberOfFrames \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -r StudyID "VHP-M-FC" -r StudyDate "19940225" -r StudyTime "000000" \
        -r StudyDescription "Cryomacrotome anatomic images" \
        -r SeriesNumber 1 \
        -r SeriesDescription "Fullcolor - direct digital" \
        -r ConversionType "DI" \
        -r PixelSpacing '.33\.33' -r SpacingBetweenSlices "1" -r SliceLocation "%" \
        -r FrameOfReferenceUID "2.25.33318953395384912699580822170414899294" \
        -r PositionReferenceIndicator "VERTEX_IS_1001" \
        -r ImagePositionPatient "0\0\-%" \
        -r ImageOrientationPatient "1\0\0\0\-1\0" \
        -r InstanceNumber "%" \
        -r Manufacturer "Leaf, Hasselblad" -r ManufacturerModelName "Digital Camera Back I, 553 ELX" -r DetectorType "CCD" \
        -r LensMake "Carl Zeiss" -r LensModel "Distagon" -r LensSpecification "50\50\4\4" -r FocalLength 50 -r FNumber "6.8" -r FilterType "POLARIZING" \
        -r DerivationDescription "Converted by dicom3tools rawtodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/Fullcolor/fullbody/a_vm%.raw" \
               "vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/Fullcolor/fullbody/a_vm%.raw" \
                                                           "vhm-data/dst/Visible-Human/Male-Images/Fullcolor/fullbody/a_vm%.dcm"
```

The 70mm Male film unregistered images that were later digitized (by a means not described in the technical report) were also converted:
```
# use different FoR than 0.33mm direct digital, since not known to be registered 
java -cp . com.pixelmed.utils.UUIDBasedOID
2.25.66103998860925857302184202630426565800

# README FILE - Male 70mm
# Anatomical Area:  TOTAL BODY(unaligned image data)
# First image file:  1001      
# Last image file:   2878      
# Type image:  COLOR 70mm film
# Frame size:  4096, 2700      
# Pixel size: .144mm,.144mm,1mm
# Image format:  RGB 24 BIT INTERLEAVED
# Header size: NONE      
# Coordinate offset:  NONE,NONE      

find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/70mm/fullbody -name '*.rgb' | xargs -I% basename '%' '.rgb' | xargs -I% \
    rawtodc -rows 2700 -columns 4096 -bits 8 -samples 3 -color-by-pixel \
        -stamp ${STAMP} -nodisclaimer \
        -r Modality "XC" -r SOPClassUID "1.2.840.10008.5.1.4.1.1.7" -r ImageType "DERIVED\PRIMARY" -r LossyImageCompression "00" -r AcquisitionContextSequence " " \
        -r BodyPartExamined WHOLEBODY -d NumberOfFrames \
        -r PatientID 'VHP-M' -r PatientName 'VisibleHumanProject^Male' \
        -r StudyID "VHP-M-FC" -r StudyDate "19940225" -r StudyTime "000000" \
        -r StudyDescription "Cryomacrotome anatomic images" \
        -r SeriesNumber 2 \
        -r SeriesDescription "70mm film - digitized" \
        -r ConversionType "DF" \
        -r PixelSpacing '.144\.144' -r SpacingBetweenSlices "1" -r SliceLocation "%" \
        -r FrameOfReferenceUID "2.25.66103998860925857302184202630426565800" \
        -r PositionReferenceIndicator "VERTEX_IS_1001" \
        -r ImagePositionPatient "0\0\-%" \
        -r ImageOrientationPatient "1\0\0\0\-1\0" \
        -r InstanceNumber "%" \
        -r Manufacturer "Rolleiflex, Eastman Kodak" -r ManufacturerModelName "6008 70-mm, Ektachrome 64T" \
        -r LensMake "Carl Zeiss" -r LensModel "Makro-planar" -r LensSpecification "120\120\4\4" -r FocalLength 120 -r FNumber "8" -r FilterType "POLARIZING\85B" \
        -r DerivationDescription "70mm film - digitized; converted by dicom3tools rawtodc" \
        -r '(0x0009,0x0010)' "PixelMed Publishing" -r '(0x0009,0x1001)' "Visible-Human/Male-Images/70mm/fullbody/%.rgb" \
               "vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Male-Images/70mm/fullbody/%.rgb" \
                                                           "vhm-data/dst/Visible-Human/Male-Images/70mm/fullbody/%.dcm"
```

The Female fullcolor images are sampled at 0.33 mm intervals rather than the 1mm intervals used for the Male, and the file names are numbered nnnn[abc], so to obtain the SliceLocation 0, 0.33, 0.66 needed to be added to the numeric slice location. This necessitated a script ["vhp_f_fc.sh"](http://github.com/ImagingDataCommons/NLM-Visible-Human-Project-DICOM-Conversion/blob/main/vhp_f_fc.sh) to perform the calculations, which was then used as follows:
```
#setenv STAMP 1677425356.1733
STAMP=1677425356.1733; export STAMP

# create unique FoR UID ...
java -cp . com.pixelmed.utils.UUIDBasedOID
2.25.71837758865959743061797451339751164512

# README FILE - Female Fullcolor
# Anatomical Area:  HEAD, THORAX, ABDOMEN, PELVIS, THIGHS, LEGS, FULLBODY
# Type image:  COLOR BIT MAPPED
# Frame size:  2048,1216      
# Pixel size: .33mm,.33mm, .33mm
# Image format:  RGB 24 BIT NON INTERLEAVED, COMPRESSED.
# Header size: NONE      
# Coordinate offset:  NONE,NONE

find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/Fullcolor/fullbody -name 'avf*.raw' \
    -exec ./vhp_f_fc.sh '{}' "vhm-data/dst/Visible-Human/Female-Images/Fullcolor/fullbody" ';'
```

The Female 70mm images were converted similarly, using the script ["vhp_f_70mm.sh"](http://github.com/ImagingDataCommons/NLM-Visible-Human-Project-DICOM-Conversion/blob/main/vhp_f_70mm.sh) (after conversion from TIFF to ppm, since dicom3tools does not support TIFF), except that the original files are numbered nnnn starting from 1001 (matching the position in the picture), so the SliceLocation is obtained by dividing the numeric part of the file name by 3 offset from 1001:
```
# create unique FoR UID ...
java -cp . com.pixelmed.utils.UUIDBasedOID
2.25.105476862367628410477813254715804995599

find vhm-data/src/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/70mm/4K_Tiff-Images -name '*.tif' | xargs -I% basename % '.tif' | xargs -I% \
    sh -c \
    'tifftopnm \
        vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/70mm/4K_Tiff-Images/%.tif \
        > vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/70mm/4K_Tiff-Images_convertedtoppm/%.ppm'

find vhm-data/src-decompressed/data.lhncbc.nlm.nih.gov/public/Visible-Human/Female-Images/70mm/4K_Tiff-Images_convertedtoppm/ -name '*.ppm' \
    -exec ./vhp_f_70mm.sh '{}' "vhm-data/dst/Visible-Human/Female-Images/70mm/4K_Tiff-Images" ';'

```

# Software Dependencies

[dicom3tools](http://www.dclunie.com/dicom3tools/workinprogress/index.html) - used for conversion of files and verifying their compliance (compiling requires apt-get install g++ make xutils-dev); a release post-20230224 is needed for a fix for a defect related to the use of a trailing null rather than space for private owners and private data elements with string VRs in copy/create/convert tools replace command line arguments.

[pixelmed.jar](http://www.dclunie.com/pixelmed/software/index.html) - used to generate new UIDs.

[bc](http://www.gnu.org/software/bc/) - used for calculations in the scripts (`apt-get install bc`).

[netpbm](https://netpbm.sourceforge.net/) - needed for tifftopnm for Female-Images/70mm/4K_Tiff-Images (`apt-get install netpbm`)

[libtiff-tools](http://www.libtiff.org/index.html) - needed for tifftopnm (`apt-get install libtiff-tools`)



