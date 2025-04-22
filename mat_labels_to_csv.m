function mat_labels_to_csv(matFilePath, outputDir)
    csvFileName = fullfile(outputDir, 'SVM_labels.csv');

    data = load(matFilePath);

    fid = fopen(csvFileName, 'w');

    fprintf(fid, ', fileName, label, confidenceInterval\n');

    if isfield(data, 'birdFileNames') && isfield(data, 'predictedLabels') && isfield(data, 'confidenceIntervals')
        for i = 1:length(data.predictedLabels)
            fn = char(data.birdFileNames(i));
            pl = string(data.predictedLabels(i));
            ci = string(data.confidenceIntervals(i));
            
            
            fn = [fn(20:end-3), 'wav']; 
            fprintf(fid, '%i,%s,%s,%s\n', i, fn, pl, ci);
        end 
    end 