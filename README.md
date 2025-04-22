# birdsong_speech_music_comp

Repository contains data analysis pipeline for music-speech similarity of birdsong in MATLAB and all recordings used. 
All code was developed on MATLAB R2023a with the complete toolbox list on Windows 10. Note: paths needs to be changed for Mac and Linux OSs. 
Scripts written by M. Pescaru, based on P.Albouy (2024)
Modulation Power Spectrum function adapted from T. Elliott and F. Theunissen (2009)

Pipeline steps: 
1. Birdsong files from xeno-canto are segmented and labeled using evsonganaly. They are then cropped, such that each file only contains one full song.
   function: >> mps_preproces
2. Computation of modulation power spectrum (MPS) for birdsong, human speech and human music. MPSs are saved in Brainstorm database.
   function: >> generate_mps(wav_directory, path_main_fold, brainstorm_protocol)
3. MPSs are used to train a SVM classifier on human music and speech files. Birdsong MPSs are used as the test data. Classifier will output a label: 2 (speech) or 1 (music) for each of the birdsong files.
   function: >> SVM_birds(path_main_fold)
4. Labels and confidence intervals are added to a Labels.csv file and saved in birdsong_speech_music_comp/output.
   function: >> mat_labels_to_csv (mat_labels, output_directory)
5. For each birdsong MPS, 3 features are computed (Assymetry, Low-Pass Coefficient and Starriness, based on definitions from Theunissen, 2003) and saved in features.csv in birdsong_speech_music_comp/output.
   function: >> extract_mps_features (mps_database, output_filename)
6. For each bird species, a figure depicting the averaged MPS is computed and saved in birdsong_speech_music_comp/output/average_species_figures
   function: >> average_species(path_main_fold)

Usage - running complete pipeline: 
1. Open MATLAB
2. If birdsong file preprocessing is not needed (i.e files are already selected for fullsongs), add them to birdsong_data folder and skip to step 5
3. If preprocessing is needed, add birdsongs with evsonganaly annotations (onsets, offsets, label) in birdsong_files_raw folder
4. Run >> mps_preprocess ('./birdsong_files_raw', './birdsong_data')
5. Download IDS_corpus_raw from zenoto website. (https://zenodo.org/record/552161) and unzip.
6. Search for all '*C.wav' files in IDS_corpus_raw and add to ./human_music_data. 
7. Search for all '*D.wav' files in IDS_corpus_raw and add to ./human_speech_data.
8. Download brainstorm (only necessary once). For instructions, see    https://neuroimage.usc.edu/brainstorm/Tutorials/CreateProtocol#Starting_Brainstorm_for_the_first_time
   Select birdsong_speech_music_comp/brainstorm_database as brainstorm databse
9. In prep_paths function, change the path_main_fold parameter to the path to the birdsong_speech_music_comp folder on your device
10. In Matlab Command Window, run: >> run_pipeline

NOTE: all MPSs are already computed and stored in the brainstorm database, so generate_mps lines in run_pipeline can be commented out and steps 2-7 can be skipped. 

Sources: birdsong files extracted from xeno-canto database (xeno-canto.org) 



