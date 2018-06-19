clear all
close all
clc 

disp('======= Tool for tagging images =======');

% options
root_dir = 'D:\Matlab IAI';
data_set = 'training';

% get sub-directories
image_dir = fullfile(root_dir,[data_set '\images']);
label_dir = fullfile(root_dir,[data_set '\labels']);

% get number of images for this dataset
%nimages = numel(size(dir(fullfile(image_dir,'*.jpeg', '*.jpg','*.png'))));
nimages = length(dir(image_dir));

% main loop
img_idx = 1;
current_img = dir(image_dir);
normal = 0;

date_types = [ "type", "truncation", "occlusion", "alpha", "x1", "y1", "x2", "y2", "h", "w", "l", "t(1)" ,"t(2)", "t(3)", "ry", "score"];
Sobjects = struct('type', 0, 'truncation', 0, 'occlusion', 0, 'alpha', 0, 'x1', 0, 'y1', 0, 'x2', 0, 'y2', 0, 'h', 0, 'w', 0, 'l', 0, 't_1', 0, 't_2', 0, 't_3', 0, 'ry', 0, 'score', 0);
init_matrix = zeros(1,16);
i = 1; %objects index  

while true
    
   while current_img(img_idx).isdir == 1
       img_idx = img_idx +1;
       normal = normal + 1;
   end
   
   img_name = current_img(img_idx).name;
   img_to_get = fullfile(image_dir, img_name);
    % create figure using size of first image in repository
    fig = figure(1);
    img = imread(img_to_get);
    imshow(img);
    % Frame number
    text(size(img,2),0,sprintf('%s set frame %d/%d',data_set,img_idx - normal,nimages-normal),'color','g','HorizontalAlignment','right','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    % usage instructions
    text(size(img,2)/2,size(img,1),sprintf('''N'': Next Image  |  ''P'': Previous Image | ''q'': quit'),'color','g','HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',14,'FontWeight','bold', 'BackgroundColor','black');
    %rectangle('Position',position,'EdgeColor','r','LineWidth',2,'LineStyle','-');
    
    % TODO - Read from .txt file of current image all the objects if there
    % are any of them that already have been tagged in the past
    
    
    
    %------------user input for interactive app-----------
    
    % TODO - change left and right arrows to skip the images
      waitforbuttonpress();
      key = get(gcf,'CurrentCharacter');     
      disp(key);
      
        switch lower(key)
            
            case 'q',  close all
                        return;                                % quit
            case 'p', if img_idx - normal ~= 1
                        img_idx = img_idx-1;  % next frame
                      else
                           img_idx = nimages;
                     end
                     continue;
            case 'n', if img_idx ~= nimages
                        img_idx = img_idx+1;  % next frame
                      else
                           img_idx = 1;
                           normal = 0;
                       end
                      continue;
            case '0', break;
            
        end

        
           
        h = imrect;
        position = wait(h);
        %pos = getPosition(h); %returns the current position of the rectangle h. The returned position, pos, is a 1-by-4 array [xmin ymin width height].     
        rectangle('Position',position,'EdgeColor','r','LineWidth',2,'LineStyle','-');
        
        
        
        
        % TODO - Make interactive changeable type of object with up and
        % down arrow keys
        
        % extract label, truncation, occlusion
        Sobjects(i).type       = 'Drone';  % 'Drone', 'Pedestrian', ...
        Sobjects(i).truncation = 0; % truncated pixel ratio ([0..1])
        Sobjects(i).occlusion  = 0; % 0 = visible, 1 = partly occluded, 2 = fully occluded, 3 = unknown
        Sobjects(i).alpha      = 0; % object observation angle ([-pi..pi])

        % extract 2D bounding box in 0-based coordinates
        Sobjects(i).x1 = position(1); % left
        Sobjects(i).y1 = position(2); % top
        Sobjects(i).x2 = position(1) + position(3); % right
        Sobjects(i).y2 = position(2) + position(4); % bottom

        % extract 3D bounding box information
        Sobjects(i).h    = 0; % box width
        Sobjects(i).w    = 0; % box height
        Sobjects(i).l    = 0; % box length
        Sobjects(i).t(1) = 0; % location (x)
        Sobjects(i).t(2) = 0; % location (y)
        Sobjects(i).t(3) = 0; % location (z)
        Sobjects(i).ry   = 0; % yaw angle

        Sobjects(i).score   = 0; % score
        
        disp(Sobjects(i));
   
        i = i + 1;
        
        prev_img_idx = img_idx;

        
       %-------------------export date to .txt file---------------------------

    % parse input file
    fid = fopen(sprintf('%s/%06d.txt',label_dir,img_idx-normal),'w');
    
    
    % TODO - add object elemnts of the same image in to the same .txt file
    % of the same current image by order from first to last
    
       
    % add object elemnt to .txt file of current image
    for i = 1:numel(Sobjects)
        fprintf(fid,'\n\n -------object number %d-------\n\n', img_idx-normal);
        % set label, truncation, occlusion
        if isfield(Sobjects(i),'type'),         fprintf(fid,'%s \n',Sobjects(i).type);
        else                                   error('ERROR: type not specified!\n'), end;
        if isfield(Sobjects(i),'truncation'),   fprintf(fid,'%.2f \n',Sobjects(i).truncation);
        else                                   fprintf(fid,'-1 \n'); end; % default
        if isfield(Sobjects(i),'occlusion'),    fprintf(fid,'%d \n',Sobjects(i).occlusion);
        else                                   fprintf(fid,'-1 \n'); end; % default
        if isfield(Sobjects(i),'alpha'),        fprintf(fid,'%.2f \n',wrapToPi(Sobjects(i).alpha));
        else                                   fprintf(fid,'-10 \n'); end; % default

        % set 2D bounding box in 0-based C++ coordinates
        if isfield(Sobjects(i),'x1'),           fprintf(fid,'%.2f\n',Sobjects(i).x1);
        else                                   error('ERROR: x1 not specified!\n'); end;
        if isfield(Sobjects(i),'y1'),           fprintf(fid,'%.2f \n',Sobjects(i).y1);
        else                                   error('ERROR: y1 not specified!\n'); end;
        if isfield(Sobjects(i),'x2'),           fprintf(fid,'%.2f \n',Sobjects(i).x2);
        else                                   error('ERROR: x2 not specified!\n'); end;
        if isfield(Sobjects(i),'y2'),           fprintf(fid,'%.2f \n',Sobjects(i).y2);
        else                                   error('ERROR: y2 not specified!\n'); end;

        % set 3D bounding box
        if isfield(Sobjects(i),'h'),            fprintf(fid,'%.2f \n',Sobjects(i).h);
        else                                   fprintf(fid,'-1 \n'); end; % default
        if isfield(Sobjects(i),'w'),            fprintf(fid,'%.2f \n',Sobjects(i).w);
        else                                   fprintf(fid,'-1 \n'); end; % default
        if isfield(Sobjects(i),'l'),            fprintf(fid,'%.2f \n',Sobjects(i).l);
        else                                   fprintf(fid,'-1 \n'); end; % default
        if isfield(Sobjects(i),'t'),            fprintf(fid,'%.2f %.2f %.2f \n',Sobjects(i).t);
        else                                   fprintf(fid,'-1000 -1000 -1000 \n'); end; % default
        if isfield(Sobjects(i),'ry'),           fprintf(fid,'%.2f \n',wrapToPi(Sobjects(i).ry));
        else                                   fprintf(fid,'-10 \n'); end; % default

        % set score
        if isfield(Sobjects(i),'score'),        fprintf(fid,'%.2f\n',Sobjects(i).score);
        else                                   error('ERROR: score not specified!\n'); end;
        
        
    end
    
    
    % close file  
    fclose(fid);
end

% clean up
close all;

















    %{ 

        objects = [date_types ; init_matrix]';

        % extract label, truncation, occlusion
        objects(1,i+1)   = 'Drone';  % 'Drone', 'Pedestrian', ...
        objects(2,i+1)  = 0; % truncated pixel ratio ([0..1])
        objects(3,i+1)   = 0; % 0 = visible, 1 = partly occluded, 2 = fully occluded, 3 = unknown
        objects(4,i+1)       = 0; % object observation angle ([-pi..pi])

        % extract 2D bounding box in 0-based coordinates
        objects(5,i+1)  = position(1); % left
        objects(6,i+1) = position(2); % top
        objects(7,i+1) = position(1) + position(3); % right
        objects(8,i+1) = position(2) + position(4); % bottom
        
        % extract 3D bounding box information
        objects(9,i+1)   = 0; % box width
        objects(10,i+1)    = 0; % box height
        objects(11,i+1)    = 0; % box length
        objects(12,i+1) = 0; % location (x)
        objects(13,i+1) = 0; % location (y)
        objects(14,i+1) = 0; % location (z)
        objects(15,i+1)   = 0; % yaw angle

        objects(16,i+1)   = 0; % score
        
        data_types = objects';
        %}
