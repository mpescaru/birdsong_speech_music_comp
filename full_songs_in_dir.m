function [song_files] = full_songs_in_dir (directoryPath, outputDirectoryPath)

      if ~isdir(outputDirectoryPath)
          error ('WARNING! NO OUTPUT DIRECTORY');
      end 

      %select the .not.mat files 
      matFiles = dir(fullfile(directoryPath, '*.not.mat'));

      %number of files with song
      song_files = 0;

      %loop through files and call full_song_file 
      for i = 1:length(matFiles)
         wavName =  matFiles(i).name(1:end-8);
         wavFilePath = fullfile(directoryPath, wavName);
         matFilePath = fullfile(directoryPath, matFiles(i).name);

         %fprintf('Computing rms values for wav file %s\n', wavName);

         [is_song, begin_sec, finish_sec, begin_index, finish_index] = full_song_file (matFilePath, 1)
         disp(wavFilePath);
        if is_song && isfile (wavFilePath)
            song_files = song_files + 1;
            newMatFilePath = fullfile(outputDirectoryPath, matFiles(i).name);
            newWavFilePath = fullfile(outputDirectoryPath, wavName); 
            copyfile(wavFilePath, newWavFilePath);
            copyfile(matFilePath, newMatFilePath);
        end
      end 

      fprintf('%i out of %i files contain a full song. That is %i percent', song_files, length(matFiles), song_files/length(matFiles)*100);