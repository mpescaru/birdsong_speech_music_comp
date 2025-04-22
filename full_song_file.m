function [is_song, begin_sec, finish_sec, begin_index, finish_index] = full_song_file (notFilePath, longest)

%%Function takes as input a .not.mat file and finds if it contains a full
%%song (begining to end) and selects either the longest or first song to
%%process

     
     %initialize values 
     is_song = 0; %becomes 1 is a full song is found
     begin_sec = 0; %becomes the onset of the chosen a (start) syllable
     finish_sec = 0; %becomes the offset of the chosen z (end) syllable 
     max_length = 0; %becomes the maximum length of a song \
     begin_index = 0; %becomes the index of the chosen a (start) syllable
     finish_index =0; %becomes the index of the chosen z (end) syllable 
     cur_s_sec = 0;
     cur_s_index =0;
    

     load(notFilePath, 'onsets', 'offsets', 'labels');
     %Load onsets and offsets from .not.mat file into vectors (converting from ms to samples)
     %onsetV = round(onsets * fs / 1000);
     %offsetV = round(offsets * fs / 1000);
     onsetV = onsets;
     offsetV = offsets;
        
     %disp (onsets);

     labelV = labels; 

     if ismember('a', labelV) && ismember('z', labelV)
     
         for i = 1:length(labelV)

             %disp([onsetV(i), offsetV(i)]);
    
             if labelV(i) == 'a'
    
                 if begin_sec == 0 
                     %%case where this s is the first one
                     begin_sec = onsetV(i);
                     begin_index = i;
                 else 
                     %%case where this is not the first s, can already have a
                     %%full song or not 
                     cur_s_sec = onsetV(i);
                     cur_s_index = i;
                 end 
             else 
                 if labelV(i) == 'z'
    
                     if begin_sec ~= 0 && finish_sec == 0
                         %%found the first end of a song (so the first song as well)
                         finish_sec = offsetV(i);
                         finish_index = i;
                         is_song = 1;
                         max_length = finish_sec - begin_sec;
                     else
                         if cur_s_index ~= 0 && longest
                             %%found the end of a non-first song; check if
                             %%longest than current longest song 
                             if (offsetV(i) - cur_s_sec) > max_length
                                %%found a song that is longer than current
                                %%maximum, this becomes the selected song
                                finish_sec = offsetV(i);
                                finish_index = i;
                                begin_sec = cur_s_sec;
                                begin_index = cur_s_index;
                                max_length = finish_sec - begin_sec;
                             end
                         end 
                     end
                 end 
             end
         end 
     end
     %disp([is_song, begin_sec, finish_sec, begin_index, finish_index]);
