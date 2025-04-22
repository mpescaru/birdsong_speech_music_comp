function mps_preproces(inputPath, outputPath)

%%Function does preprocessing: crops out song and adds 200 ms silence before and after 
%%Parameters:
%directoryPath - directory with .wav and .not.mat files 
%outputPath - directory where processed .wav (and .mat) files will be stored
%given file (the first is selected by default)
      addpath(inputPath);

      %select the .not.mat files 
      matFiles = dir(fullfile(inputPath, '*.not.mat'));

      %number of files with song
      song_files = 0;

      %loop through files and call full_song_file 
      for i = 1:length(matFiles)
        wavName = matFiles(i).name(1:end-8);
        wavFilePath = fullfile(inputPath, wavName);
        if isfile(wavFilePath)
            
            [Y, fs] = audioread(wavFilePath);
            %disp(fs);
            matFilePath = fullfile(inputPath, matFiles(i).name);
            matName = matFiles(i).name;

            %fprintf('Computing rms values for wav file %s\n', wavName);

            [is_song, start_sec, end_sec, start_index, end_index] = full_song_file (matFilePath, 1);
            if fs < 22500 
                disp(wavFilePath)
            end 
            if is_song && fs >= 22000
                song_files = song_files + 1;
                process_file(start_sec, end_sec, start_index, end_index, wavName, matName, outputPath, wavFilePath, matFilePath);
            end
        end 
      end 

      fprintf('%i out of %i files contain a full song.\n', song_files, length(matFiles));



function process_file(start_sec, end_sec, start_index, end_index, wavName, matName, outputPath, wavFilePath, matFilePath);
      
    
    

    %%create new file paths 
    matFilePathNew = fullfile(outputPath, matName);
    wavFilePathNew = fullfile(outputPath, wavName);
    
    
    %%read audio and annotation data 
    [audioData, fs] = audioread(wavFilePath);
    load(matFilePath, 'onsets', 'offsets', 'labels', 'Fs', 'fname', 'min_dur', 'min_int', 'sm_win', 'threshold');

    
    %%check if the song has 200 ms of silence before and after 
    song_length = length(audioData)/fs*1000;
    if start_sec > 200 && song_length - end_sec > 200
    
        %%crop and save annotation file 
        
        onsets = onsets(start_index:end_index);
        offsets = offsets(start_index:end_index);
        labels = labels(start_index:end_index);
        save(matFilePathNew, 'onsets', 'offsets', 'labels', 'Fs', 'fname', 'min_dur', 'min_int', 'sm_win', 'threshold');
        
        
        cropLeft = (start_sec - 200)*fs/1000;
        cropRight = (end_sec + 200) * fs/1000; 
        disp(cropLeft); 
        disp(cropRight); 
        croppedAudio = audioData(cropLeft:cropRight);
        audiowrite(wavFilePathNew, croppedAudio, fs);
    end 
    
            





    





