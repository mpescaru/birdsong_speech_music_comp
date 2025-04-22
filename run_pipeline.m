function run_pipeline

    prep_paths;
    
    generate_mps('birdsong_data', path_main_fold, brainstorm_protocol);
    generate_mps('human_music_data', path_main_fold, brainstorm_protocol);
    generate_mps('human_speech_data', path_main_fold, brainstorm_protocol);
    
    SVM_birds(path_main_fold);
    mat_labels_to_csv(fullfile(path_main_fold, 'output\predictedLabelsWithNames.mat'), fullfile(path_main_fold, 'output')); 


    extract_mps_features(fullfile(path_main_fold, '\brainstorm_database\STM\data\ADS_Corpus\ADS'), fullfile(path_main_fold, '\output\mps_features.csv')); 

    average_species(path_main_fold)
end 