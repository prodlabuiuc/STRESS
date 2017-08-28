%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRESS.m                             %
% Phonotactic Stress 1 - 2 day study  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Based on: pr2.m
%     % A script for running phonotactic learning experiments as described in
%     % Dell, Reed, Adams, & Meyer 2000 (JEP:LMC)
%     %
%     % Subjects repeat words once at 1 syllable per second (60 bpm), and then 3
%     % times at 2.53 syllables per second (151.8 bpm). (period of 0.395 s)
%     %
%     % Nathaniel Anderson (nathanieldanderson@gmail.com)
%     % March 2014
%     %
%     % Updated August 2014 to run 3-day 2nd order constraint experiment
%     % (A|AB|BA)
%     %
%     % Dependencies: psychtoolbox, cogtoolbox

clear all;
close all;

%%%% Set to 1 to disable instructions for debugging %%%%
testmode = 0;

%% Set variables and initialize Psychtoolbox

% set path
in_dir = '/Users/prodlab3/Desktop/STRESS/in_files/';
out_dir = '/Users/prodlab3/Desktop/STRESS/out_files/';


% initialize psychtoolbox
Screen('CloseAll');
try
    PsychPortAudio('Close');
catch
end
%InitExperiment;
Screen('Preference','SkipSyncTests',0); % CHANGE THIS TO ZERO LATER!
InitializePsychSound;

% set parameters
behav_prefix = 'str';
subjnum_length = 2;
time_before_sound = 0.25;
sound_freq = 44100;
n_bits = 16;
myrec = audiorecorder(sound_freq, n_bits, 1);
text_size = 24; %16 on 1428 computer
text_font = 'Arial'; %'Times New Roman';
bg_color = [10 10 10]; % background color
fg_color = [255 255 255]; % text color
text_position = 200;

long_pause = 1.0; % in secs
short_pause = 0.65; % in secs
countdown = {'4','3','2','1'};

%% Get subject number, load list, open output file

% prompt experimenter for subject number
while 1
    subjnum = input('Subject number: ');
    daynum = input('Day number: ');
    
    % see if a recording exists with this combination of numbers:
    output_file = [out_dir behav_prefix 's' sprintf('%02d',subjnum) ...
        'd' num2str(daynum) 't01.wav'];
    if exist(output_file, 'file')==0
        % the file does not exist, so break out of this loop & use the
        % entered values
        break
    else
        % output file already exists with that subject # and day #
        fprintf(['Output file already exists for this combination of ' ...
            'subject number and day number!\n']);
        overwrite = upper(inputstring(['Do you want to overwrite the ' ...
            'old file? - (Y)es or (N)o?: ']));
        if strcmp(overwrite,'Y') || strcmp(overwrite, 'YES')
            % OK, we're going to overwrite the old files
            break
        end % otherwise, they will just get prompted for the subject number
    end
end

% load correct list file

list_files = {'DK1';
            'FSH1';
            'KD1';
            'MN1';
            'NM1';
            'SHF1';
            'DK2';
            'FSH2';
            'KD2';
            'MN2';
            'NM2';
            'SHF2';
            'DK3';
            'FSH3';
            'KD3';
            'MN3';
            'NM3';
            'SHF3';};

list_file = [list_files{subjnum} 'day' num2str(daynum) '.txt'];


% read list
fid = fopen([in_dir 'lists/' list_file]);
C = textscan(fid, '%s %s %s %s');
list = horzcat(C{1}, C{2}, C{3}, C{4});
n_trials = size(list,1);

% open output file --- but at this point, there's nothing to write to it
% outfile = fopen(output_file, 'w');

fprintf('Please wait - loading experiment... \n');

%% Set up visuals

% Open the screen
[expwindow, rect] = Screen('OpenWindow', 0, bg_color);
Screen('TextSize', expwindow, text_size);
Screen('TextFont', expwindow, text_font);
Screen('TextStyle', expwindow, 0); % change default font to non-bold
Screen('TextColor', expwindow, [255, 255, 255]);

%% Set up sound

% This opens a channel on the sound card
pahandle = PsychPortAudio('Open', [], 1, 1, sound_freq, 1, [], 0.015);
slow_metronome = audioread([in_dir 'sounds/slow_metronome.wav']);
slow_metronome = slow_metronome';
fast_metronome = audioread([in_dir 'sounds/fast_metronome.wav']);
fast_metronome = fast_metronome';

low_tone = audioread([in_dir 'sounds/tone880.wav']);
low_tone = low_tone';
mid_tone = audioread([in_dir 'sounds/tone1000.wav']);
mid_tone = mid_tone';
high_tone = audioread([in_dir 'sounds/tone1760.wav']);
high_tone = high_tone';
trochaic_reminder=audioread([in_dir 'sounds/trochaic_reminder.wav']);
trochaic_reminder=trochaic_reminder';
iambic_reminder=audioread([in_dir 'sounds/iambic_reminder.wav']);
iambic_reminder=iambic_reminder';

%% Instructions
if testmode==0
%% Present instructions (day 1 only)
if daynum==1

    instructions = ['Instructions: \n\n In this experiment, you will '...
        'be reading nonsense words aloud in time with a metronome.'...
        '\n\nOn the next screen, you will practice the task. '...
        'Syllables will be capitalized in order to indicate stress. '...
        'Treat this stress like you would in English and emphasize the syllable accordingly. '...
        '\n\nFor example, "TOken TOken" vs. "beLONG beLONG"'...
        '\n\nThe only vowel in the experiment trials is "i" and is always pronounced as "i" in "fit". Do NOT pronounce it as "u" in "cactus".'...
        '\n\n\n\nPress any key to begin.'];
    [~, ~, ~] = DrawFormattedText(expwindow, instructions, 'center', ...
        'center', fg_color, 80);
    Screen('Flip',expwindow);
    WaitSecs(0.05);
    getKeys;
    
    %% no-beep practice 1
    trialNoBeep = 'VIZbing HIGsip\n\n\n\nStress the capitalized syllable as you would in: TOken TOken';
    DrawFormattedText(expwindow, trialNoBeep, 'center', ...
                'center', fg_color, 80)
    Screen('Flip', expwindow);
    WaitSecs(0.05);
    getKeys;
    %% no-beep practice 2
    trialNoBeep = 'vizBING higSIP\n\n\n\nStress the capitalized syllable as you would in: beLONG beLONG';
    DrawFormattedText(expwindow, trialNoBeep, 'center', ...
                'center', fg_color, 80)
    Screen('Flip', expwindow);
    WaitSecs(0.05);
    getKeys;

    %% Give practice instructions
    instructions = ['Practice Trial:\n\n '...
        'In the next two practice trials, you will say the sequences with beeps. Time the stressed syllable with the beep. You will say each sequence 2 time slowly and 3 times fast.\n\n'...
        'Do not speak when "PREPARE" appears.. \nWhen "GO!" appears, get ready to speak. \nAs soon as "SPEAK" appears, you start speaking.'...
        '\nIf you make a mistake, keep going and try not to slow down.\n\n\n\n'...
        'Press any key to start the practice trial.'];

    DrawFormattedText(expwindow, instructions, 'center', ...
        'center', fg_color, 80);
    Screen('Flip',expwindow);
    WaitSecs(0.05);
    getKeys;

    %% Run practice trials
    practice = 0;
    while practice==0   
        %% Prepare for trial
        trial_sylls = ['VIZbing HIGsip'];
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);

        PsychPortAudio('FillBuffer', pahandle, low_tone);

        %% Slow countdown
        WaitSecs(long_pause);
        Screen('Flip', expwindow);

        % Start slow beep countdown loop
        sl=2;
        for j = 1:4

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);

            % Prepare countdown
            number = countdown{j};
            if j<4
                DrawFormattedText(expwindow,['PREPARE - ' (number-1)], 'center', ...
                    text_position, fg_color, 80);
            else
                DrawFormattedText(expwindow,'GO!', 'center', ...
                    text_position, fg_color, 80);
            end
            % Flip and play sound
            Screen('Flip',expwindow);
            if j<4
                PsychPortAudio('Start', pahandle);
                WaitSecs(long_pause);
            elseif j==4
                PsychPortAudio('FillBuffer', pahandle, high_tone);
                PsychPortAudio('Start', pahandle);
                PsychPortAudio('FillBuffer', pahandle, low_tone);
                WaitSecs(long_pause);
            end
        end

        %% Slow sequence
        
        for k = 1:2 % 2 SLOW REPS
            % Prepare instructions        
            DrawFormattedText(expwindow, ['SPEAK - ' num2str(k)], ...
                'center', text_position, fg_color, 80);

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            
            % Flip screen
            Screen('Flip', expwindow);
            % Start slow beep loop
            for j = 1:sl
                PsychPortAudio('Start', pahandle);
                WaitSecs(long_pause);
            end
        end

        %% Fast countdown

        % Start fast beep countdown loop
        for j = 1:4
            % Prepare countdown
            number = countdown{j};
            if j<4
                DrawFormattedText(expwindow, ['PREPARE - ' number], 'center', ...
                    text_position, fg_color, 80);
            else 
                DrawFormattedText(expwindow, 'GO!', 'center', ...
                    text_position, fg_color, 80);
            end
            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            % Flip screen
            Screen('Flip', expwindow);

            if j<4
                PsychPortAudio('Start', pahandle);
                WaitSecs(short_pause);
            elseif j==4
                PsychPortAudio('FillBuffer', pahandle, high_tone);
                PsychPortAudio('Start', pahandle);
                PsychPortAudio('FillBuffer', pahandle, low_tone);
                WaitSecs(short_pause);
            end
        end

        %% Fast sequence
        for k = 1:3 % 3 FAST REPS
            % Prepare instructions        
            DrawFormattedText(expwindow, ['SPEAK - ' num2str(k)], ...
                'center', text_position, fg_color, 80);

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            
            % Flip screen
            Screen('Flip', expwindow);
            % Start fast beep loop
            for j = 1:sl
                PsychPortAudio('Start', pahandle);
                WaitSecs(short_pause);
            end
        end

        message=['Press 1 to finish the current practice and go on to the '...
            'next practice. \n\nPress any other key to do the current practice again.'];
        [nx, ny, bbox] = DrawFormattedText(expwindow, message, ...
            'center', 'center', fg_color, 80);
        Screen('Flip',expwindow);

        key = getKeys;
        if key==30
            practice = 1;
        end

    end
    
        %% Run practice trials 2
    practice = 0;
    while practice==0   
        %% Prepare for trial
        trial_sylls = ['vizBING higSIP'];
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);

        PsychPortAudio('FillBuffer', pahandle, low_tone);

        %% Slow countdown
        WaitSecs(long_pause);
        Screen('Flip', expwindow);

        % Start slow beep countdown loop
        sl=2;
        for j = 1:4

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);

            % Prepare countdown
            number = countdown{j};
            if j<4
                DrawFormattedText(expwindow,['PREPARE - ' (number-1)], 'center', ...
                    text_position, fg_color, 80);
            else
                DrawFormattedText(expwindow,'GO!', 'center', ...
                    text_position, fg_color, 80);
            end
            % Flip and play sound
            Screen('Flip',expwindow);
            if j<4
                PsychPortAudio('Start', pahandle);
                WaitSecs(long_pause);
            elseif j==4
                PsychPortAudio('FillBuffer', pahandle, high_tone);
                PsychPortAudio('Start', pahandle);
                PsychPortAudio('FillBuffer', pahandle, low_tone);
                WaitSecs(long_pause);
            end
        end

        %% Slow sequence
        
        for k = 1:2 % 2 SLOW REPS
            % Prepare instructions        
            DrawFormattedText(expwindow, ['SPEAK - ' num2str(k)], ...
                'center', text_position, fg_color, 80);

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            
            % Flip screen
            Screen('Flip', expwindow);
            % Start slow beep loop
            for j = 1:2
                PsychPortAudio('Start', pahandle);
                WaitSecs(long_pause);
            end
        end

        %% Fast countdown

        % Start fast beep countdown loop
        for j = 1:4
            % Prepare countdown
            number = countdown{j};
            if j<4
                DrawFormattedText(expwindow, ['PREPARE - ' number], 'center', ...
                    text_position, fg_color, 80);
            else 
                DrawFormattedText(expwindow, 'GO!', 'center', ...
                    text_position, fg_color, 80);
            end
            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            % Flip screen
            Screen('Flip', expwindow);

            if j<4
                PsychPortAudio('Start', pahandle);
                WaitSecs(short_pause);
            elseif j==4
                PsychPortAudio('FillBuffer', pahandle, high_tone);
                PsychPortAudio('Start', pahandle);
                PsychPortAudio('FillBuffer', pahandle, low_tone);
                WaitSecs(short_pause);
            end
        end

        %% Fast sequence
        for k = 1:3 % 3 FAST REPS
            % Prepare instructions        
            DrawFormattedText(expwindow, ['SPEAK - ' num2str(k)], ...
                'center', text_position, fg_color, 80);

            % Prepare syllables
            DrawFormattedText(expwindow, trial_sylls, 'center', ...
                'center', fg_color, 80);        
            
            % Flip screen
            Screen('Flip', expwindow);
            % Start fast beep loop
            for j = 1:2
                PsychPortAudio('Start', pahandle);
                WaitSecs(short_pause);
            end
        end

        message=['Press 1 to finish the practice and go on to the '...
            'experiment. \n\nPress any other key to practice again.'];
        [nx, ny, bbox] = DrawFormattedText(expwindow, message, ...
            'center', 'center', fg_color, 80);
        Screen('Flip',expwindow);

        key = getKeys;
        if key==30
            practice = 1;
        end

    end
   
    

    %% Give final instructions before beginning experiment
    instructions = ['In the real experiment, you will be saying nonsense words.\n\n '...
        '\nSTRESS:\n'...
        'A part of syllables in the experiment will be capitalized in order to indicate stress. '...
        'Treat this stress like you would in English and change your tone of voice accordingly. '...
        '\n\nFor example, "TOken TOken" vs. "beLONG beLONG"'...
        '\n\n\n\nPress any key to move to the next page of instructions.'];
    [~, ~, ~] = DrawFormattedText(expwindow, instructions, 'center', ...
        'center', fg_color, 80);
    Screen('Flip',expwindow);
    WaitSecs(0.05);
    getKeys;

    instructions = ['You will likely make many errors during the '...
        'experiment. When you '...
        'do, continue with the trial and try not to slow down.'...
        '\n\nIf you have any questions, please ask the experimenter '...
        'now. '...
        '\n\n\n\nPress any key to begin the experiment.'];
    DrawFormattedText(expwindow, instructions, 'center', ...
        'center', fg_color, 80);
    Screen('Flip',expwindow);
    WaitSecs(0.05);
    getKeys;
else
        instructions = 'Press any key to begin the experiment.';
    DrawFormattedText(expwindow, instructions, 'center', ...
        'center', fg_color, 80);
    Screen('Flip',expwindow);
    WaitSecs(0.05);
    getKeys;
end
end


%% Run trials
for i = 1:n_trials
    %%Show Reminder every 10 trials
    if mod(i,10)==1
        DrawFormattedText(expwindow, ['Next two screens are reminders'...
            'of how to pronounce the stress. Please follow strictly.'],...
            'center', 'center', fg_color, 80);
        Screen('Flip', expwindow);
        getKeys;
        DrawFormattedText(expwindow, ['Stress on the 1st syllable\n\n\n'...
            'VIZbing HIGsip'],...
            'center', 'center', fg_color, 80);
        PsychPortAudio('FillBuffer', pahandle, trochaic_reminder);
        PsychPortAudio('Start', pahandle);
        Screen('Flip', expwindow);
        getKeys;
        DrawFormattedText(expwindow, ['Stress on the 2nd syllables\n\n\n'...
            'vizBING higSIP'],...
            'center', 'center', fg_color, 80);
        PsychPortAudio('FillBuffer', pahandle, iambic_reminder);
        PsychPortAudio('Start', pahandle);
        Screen('Flip', expwindow);
        getKeys;
    end    
    %% Prepare for trial
    trial_sylls = [list{i,1}, ' ', list{i,2}, ' ', list{i,3}, ' ', ...
        list{i,4}];
    DrawFormattedText(expwindow, trial_sylls, 'center', ...
            'center', fg_color, 80);
        
    PsychPortAudio('FillBuffer', pahandle, low_tone);
    
    % Start recording
    record(myrec);
    
    %% Slow countdown
    WaitSecs(0.1);
    Screen('Flip', expwindow);
    
    % Start slow beep countdown loop
    for j = 1:4

        % Prepare syllables
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
            'center', fg_color, 80);
        
        % Prepare countdown
        number = countdown{j};
        if j<4
            DrawFormattedText(expwindow, ['PREPARE - ' (number-1)], 'center', ...
                text_position, fg_color, 80);
        else
            DrawFormattedText(expwindow, 'GO!', 'center', ...
                text_position, fg_color, 80);
 
        end
        % Flip and play sound
        Screen('Flip',expwindow);
        if j<4
            PsychPortAudio('Start', pahandle);
            WaitSecs(long_pause);
        elseif j==4
            PsychPortAudio('FillBuffer', pahandle, high_tone);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('FillBuffer', pahandle, low_tone);
            WaitSecs(long_pause);
        end
    end
    
    %% Slow sequence
    for times=1:2
        % Prepare instruction
        DrawFormattedText(expwindow, ['SPEAK ' num2str(times)], 'center', ...
            text_position, fg_color, 80);

        % Prepare syllables
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
            'center', fg_color, 80);  

        % Flip screen
        Screen('Flip', expwindow);

        % Start slow beep loop
        for j = 1:2 % (beep beep beep beep)
            PsychPortAudio('Start', pahandle);
            WaitSecs(long_pause);
        end
    end
    
    %% Fast countdown
    
    % Start fast beep countdown loop
    for j = 1:4
        % Prepare countdown
        number = countdown{j};
        if j<4
            DrawFormattedText(expwindow, ['PREPARE - ' number], 'center', ...
                text_position, fg_color, 80);
        else
            DrawFormattedText(expwindow, 'GO!', 'center', ...
                text_position, fg_color, 80);
        end
        % Prepare syllables
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
            'center', fg_color, 80);        
        % Flip screen
        Screen('Flip', expwindow);

        if j<4
            PsychPortAudio('Start', pahandle);
            WaitSecs(short_pause);
        elseif j==4
            PsychPortAudio('FillBuffer', pahandle, high_tone);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('FillBuffer', pahandle, low_tone);
            WaitSecs(short_pause);
        end
    end
    
    %% Fast sequence

    for k = 1:3 % 3 FAST REPS
        % Prepare instructions
        DrawFormattedText(expwindow, ['SPEAK - ' num2str(k)], ...
            'center', text_position, fg_color, 80);
        
        % Prepare syllables
        DrawFormattedText(expwindow, trial_sylls, 'center', ...
            'center', fg_color, 80);        
        % Flip screen
        Screen('Flip', expwindow);

        % Start fast beep loop
        for j = 1:2
            PsychPortAudio('Start', pahandle);
            WaitSecs(short_pause);
        end
    end
    
    %% Stop recording and save file
    WaitSecs(short_pause);
    stop(myrec);

    % save audio file
    recording = getaudiodata(myrec);
    filename = [behav_prefix 's' sprintf('%02d',subjnum) 'd' ...
        num2str(daynum) 't', sprintf('%02d', i) '.wav'];
    wavwrite(recording, sound_freq, n_bits, [out_dir filename]);
    
    % Show between-trial screen, wait for key press
    DrawFormattedText(expwindow, 'Press any key to continue.',...
         'center', 'center', fg_color, 80);   
    Screen('Flip', expwindow);
    % wait for subject to press a key
    getKeys;
 
end

%% Farewell screen
message=['You have completed this session! '...
    'Please let the experimenter know that you have finished.'];
[nx, ny, bbox] = DrawFormattedText(expwindow, message, 'center', ...
    'center', fg_color, 80);
Screen('Flip',expwindow);
getKeys;


%% Close things
Screen('CloseAll');
PsychPortAudio('Close');
fclose all;
fprintf('Experiment ended successfully!  Thank you!\n');
