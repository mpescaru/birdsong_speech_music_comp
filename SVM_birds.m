function SVM_birds(path_main_fold)
    %%% function trains SVM on speech and music data from the brainstorm
    %%% database and outputs speech (2) / music (1) labels for birdsong
    %%% files

    
    dsp = 2;
    %%extract training and testing data 
    dbPath = fullfile(path_main_fold, '\brainstorm_database\STM\data\ADS_Corpus\ADS');
    songFiles = dir(fullfile(dbPath, 'timefreq_morlet_S3*C.mat'));
    speechFiles = dir(fullfile(dbPath, 'timefreq_morlet_S3*D.mat'));
    birdFiles = dir(fullfile(dbPath, 'timefreq_morlet_S3_seg__species*.mat'));
    predictionFile = fullfile(path_main_fold, 'output\predictedLabelsWithNames.mat');
    disp(length(birdFiles));


    %%select features and labels for train data 

    %%%feature and label extraction

    %%initialize empty arrays
    training_featuresC = [];
    training_featuresD = [];
    training_labelsC = [];
    training_labelsD = [];
    
    %%loop through each file
    for ty = 1:min(length(songFiles), length(speechFiles))
    
        %%loads TF information from one song and corresponding speech file 
        tfc = load(fullfile(dbPath,songFiles(ty).name));
        tfd = load(fullfile(dbPath,speechFiles(ty).name));
 
        %%normalization 
        iC = squeeze(tfc.TF(1,:,:));
        iD = squeeze(tfd.TF(1,:,:));
 
        IT = [iC iD];
        normT = IT - min(IT(:));
        normT = normT ./ max(normT(:));

        normC = normT(:,1:size(iC,2));
        normC = downsample(normC,dsp);
        normC = normC';
        normC = downsample(normC,dsp);
        normC = normC';

        normD = normT(:,size(iD,2)+1:end);
        normD = downsample(normD,dsp);
        normD = normD';
        normD = downsample(normD,dsp);
        normD = normD';

        %%training feature extraction 
        training_featuresC(ty, :) =  reshape(normC,1,[]);
        training_featuresD(ty, :) =  reshape(normD,1,[]);
        training_labelsC(ty, :)  = 1; %%one for song
        training_labelsD(ty, :)  = 2; %%two for speech 
    end

    %%select features from test data 
    
    %initialize empty array 
    test_features = [];

    birdFileNames = strings(length(birdFiles));
    %loop through test(i. e. bird) files 
    for ty = 1:(length(birdFiles)/2)
        tfb1 = load(fullfile(dbPath, birdFiles(ty).name));
        tfb2 = load(fullfile(dbPath, birdFiles(ty+floor(length(birdFiles)/2)).name));
        birdFileNames(ty) = birdFiles(ty).name;
        birdFileNames(ty+floor(length(birdFiles)/2)) = birdFiles(ty+floor(length(birdFiles)/2)).name;
        iB1 = squeeze(tfb1.TF(1, :, :));
        iB2 = squeeze(tfb2.TF(1, :, :));
        IT = [iB1 iB2];
        normT = IT - min(IT(:));
        normT = normT ./ max(normT(:));

        normB1 = normT(:,1:size(iB1,2));
        normB1 = downsample(normB1,dsp);
        normB1 = normB1';
        normB1 = downsample(normB1,dsp);
        normB1 = normB1';

        normB2 = normT(:,size(iB2,2)+1:end);
        normB2 = downsample(normB2,dsp);
        normB2 = normB2';
        normB2 = downsample(normB2,dsp);
        normB2 = normB2';
        test_featuresB1(ty, :) = reshape(normB1, 1, []);
        test_featuresB2(ty, :) = reshape(normB2, 1, []);
    end
    
    test_features = [test_featuresB1; test_featuresB2];
    %%train 
   
    %concatenate training arrays 
    training_features = [training_featuresC; training_featuresD];
    training_labels = [training_labelsC; training_labelsD];

    % fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
    classifier = fitcecoc(training_features, training_labels);
    
    %%test = generate labels for testing data 
    [predictedLabels, confidenceIntervals] = predict(classifier, test_features);

    %%save labels into csv file 
    disp(predictedLabels);
    save(predictionFile, "predictedLabels", "confidenceIntervals", "birdFileNames");
    cd (path_main_fold);
   
