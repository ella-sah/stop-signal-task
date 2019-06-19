% General parameters
clear all;
Screen('Preference', 'SkipSyncTests', 1);

ErrorDelay=1; interTrialInterval=1; nTrialsPerBlock = 10; 

KbName('UnifyKeyNames');
Key1=KbName('LeftArrow');
Key2=KbName('RightArrow');
spaceKey = KbName('space');
escKey = KbName('ESCAPE');
corrkey = [80, 79]; % Left arrow (80) + right arrow (79)
gray = [127 127 127]; white = [255 255 255]; black = [0 0 0];
bgcolor = white;
textcolor = black;

% Set up sound stimuli
BeepFreq = [400 1400 0]; BeepDur = [.1 .1 .2];
Beep1 = MakeBeep(BeepFreq(1), BeepDur(1));
Beep2 = MakeBeep(BeepFreq(2), BeepDur(2));
Beep3 = MakeBeep(BeepFreq(3), BeepDur(3));
Beep4 = [Beep1 Beep3 Beep1];
Beep5 = [Beep2 Beep3 Beep2];

% Login prompt + open file for writing data
prompt = {'Outputfile', 'Subject''s number:', 'age', 'gender', 'group', 'Num of Blocks'};
defaults = {'StopSignalTask', '1', '18', 'F', 'control' , '8'};
answer = inputdlg(prompt, 'StopSignalTask', 2, defaults);
[output, subid, subage, gender, group, nBlocks] = deal(answer{:}); % All input vars are strings
outputname = [output gender subid group subage '.xls'];
nblocks = str2num(nBlocks); % Convert string to number for reference

if exist(outputname)==2 % Check to avoid overiding existing file
    fileproblem = input('File already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) || fileproblem==3
        return;
    elseif fileproblem==1
        outputname = [outputname '.x'];
    end
end
outfile = fopen(outputname,'w'); % Open file for writing data
fprintf(outfile, 'Subid\t Subage\t Gender\t Group\t BlockNumber\t TrialNumber\t LeftRightNull\t Accuracy\t ReactionTime\t \n');

% Screen parameters
[mainwin, screenrect] = Screen(0,'OpenWindow');
Screen('FillRect',mainwin,bgcolor); 
center = [screenrect(3)/2 screenrect(4)/2];
Screen(mainwin, 'Flip');

% Load image (fixation cross)
im = imread('cross.jpg'); cross = Screen('MakeTexture',mainwin,im);
im = imread('gocross.jpg'); gocross = Screen('MakeTexture',mainwin,im);

% For location to place fixation cross
nrow = 6; ncolumn = 6; cellsize = 100;

% Experimental instructions + wait for spacebar response to start
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,24);
Screen('DrawText',mainwin,'Welcome to the SPL!',center(1)-130,center(2)-80,textcolor);
Screen('DrawText',mainwin,'Report the pitch of the beep: press left arrow for low pitch, right arrow high pitch, but do not respond to 2 beeps.',center(1)-600,center(2)-20,textcolor);
Screen('DrawText',mainwin,'Press spacebar to begin with examples of low and high pitches.',center(1)-350,center(2)+40,textcolor);
Screen('Flip',mainwin);

keyIsDown=0;
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(0.3);

% Example low pitch
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,24);
Screen('DrawText',mainwin,'Press spacebar for an example of LOW pitch.',center(1)-200,center(2),textcolor);
Screen('Flip',mainwin);

keyIsDown=0;
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(1);
Snd('Play',Beep1);
WaitSecs(2);

% Example high pitch
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,24);
Screen('DrawText',mainwin,'Press spacebar for an example of HIGH pitch.',center(1)-200,center(2),textcolor);
Screen('Flip',mainwin);

keyIsDown=0;
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(1);
Snd('Play',Beep2);
WaitSecs(2);

% Start experiment
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,24);
Screen('DrawText',mainwin,'Press spacebar to start the experiment.',center(1)-200,center(2),textcolor);
Screen('Flip',mainwin);

keyIsDown=0;
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(0.3);

if mod(str2num(subid),2)==0
    firstblock=1;  
else
    firstblock=0;
end

outcomes = [];
allRT = [];

% Block loop
for a = 1:str2num(nBlocks)
    Screen('FillRect',mainwin,bgcolor);
    Screen('TextSize',mainwin,24);
    
    Screen('DrawText',mainwin,'Left arrow for low pitch, right arrow for high pitch, no response if 2 beeps.',center(1)-360,center(2)-50,textcolor);
    Screen('DrawText',mainwin,'Click to start. Respond as soon as the fixation cross turns blue.',center(1)-360,center(2),textcolor);
    Screen('Flip',mainwin);
    GetClicks;
    
    itemloc = [center(1)-cellsize/2, center(2)-cellsize/2, center(1)+cellsize/2, center(2)+cellsize/2];
    Screen('FillRect',mainwin,bgcolor);
    Screen('DrawTexture',mainwin,cross,[],itemloc);
    Screen('Flip',mainwin);
    
    % Trial loop
    for i = 1:nTrialsPerBlock
    
        stopsig = randi(4); % Randomize left + right + no-response (type 3/4) trials
        
        % Present stimulus
        if stopsig==1 % 1 low pitch
            Snd('Play',Beep1);
            answer=1; % Left resp expected
        elseif stopsig==2 % 1 high pitch
            Snd('Play',Beep2);
            answer=2; % Right resp expected 
        elseif stopsig==3 % 2 low
            Snd('Play',Beep4);
            answer=3; % No resp expected
        elseif stopsig==4 % 2 high
            Snd('Play',Beep5);
            answer=3; % No resp expected
        end
        
        WaitSecs(.5);
        
        % Record response + reaction time
        timeStart = GetSecs;keyIsDown=0;correct=0;rt=0;

        while 1 && (GetSecs-timeStart) < 2 % Allow 2 secs to respond
            Screen('DrawTexture',mainwin,gocross,[],itemloc); % Go signal for keyboard response (visual)
            Screen('Flip',mainwin);
           [keyIsDown,secs,keyCode] = KbCheck;
            FlushEvents('keyDown');
            if keyIsDown
                nKeys = sum(keyCode);
                if nKeys==1
                    if keyCode(Key1) || keyCode(Key2)
                        rt = 1000.*(GetSecs-timeStart);
                        keypressed=find(keyCode);
                        break;
                    elseif keyCode(escKey)
                        ShowCursor;
                        fclose(outfile);
                        Screen('CloseAll'); return
                    end
                    keyIsDown=0;
                    keyCode=0;
                end
            else
                keypressed=0;
            end
        end
                
        Screen('DrawTexture',mainwin,cross,[],itemloc);
        Screen('Flip',mainwin);
        
        if keypressed==0 % No response after 2 secs (timeout OR inhibition for type 3/4)
            rt=0; % Not applicable here
        end
            
        if (keypressed==corrkey(1) && answer==1) || (keypressed==corrkey(2) && answer==2) || (keypressed==0 && answer==3)
            correct=1;
        else
            correct=0;
            WaitSecs(ErrorDelay);
        end
        
        % Write data in Excel file
        fprintf(outfile, '%s\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %6.2f\t \n', subid, ...,
            subage, gender, group, a, i, answer, correct, rt);
        WaitSecs(interTrialInterval);
        
        outcomes = [outcomes,correct];
        if rt ~= 0
            allRT = [allRT,rt];
        end
        
    end % End trial loop
end % End block loop

Screen('CloseAll');
fclose(outfile);  
fprintf('\n\n\n\n\nFinished!\n\n');

successRate = mean(outcomes)
meanReacTime = mean(allRT)