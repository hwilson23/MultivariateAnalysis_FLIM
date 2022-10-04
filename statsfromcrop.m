function [out] = statscroppedfiles(folder, ccvlist, chilist, intensitylist, imdis,laserclassifiedname) 


%THIS FUNCTION IS DESIGNED TO USE CROPPED SEGMENTS OF THE IMAGE AND
% RETURN STATISTICS FOR EACH FILE. WORKS WITHOUT THE TEXT FILE
%INPUTS, BUT HAS NO SORTING OF THE DATA

%Check to make sure same number of files

if length(ccvlist) == length (chilist) && length (intensitylist) == length(ccvlist)
    disp(["Number of files: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
else
    disp("ERROR: Lengths of file lists may differ for each type of file.")
    disp(["File numbers: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
    
    return
end 

%will get added information out of the file names, such as laser power
%classification
laserclassification = [];
if laserclassifiedname == 1
    for i = 1:length(ccvlist)
    nameinfo = strsplit(ccvlist(i),'_');
    laserclassification = [laserclassification; nameinfo(3)]
    end 
else
    disp("laserclassifiedname = 0, no info from file name")
    laserclassification = zeros(length(ccvlist))
end

add = 0;
varTypes = ["string", "string", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["CCVFileName", "CHIFileName", "INTFileName", "LaserClassification", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "PhotonsMean", "PhotonsMedian", "PhotonsSTDEV"];
out = table('Size', [length(ccvlist), length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
for num = 1:length(ccvlist)
    add = add+1

    intensity = dlmread(string(strcat(folder, '\',intensitylist(num))));
    size(intensity);
    inttopleft = intensity(1:128,1:128);
    
    inttopright = intensity(1:128, 129:end);
    intbtmleft = intensity(129:end, 1:128);
    intbtmright = intensity(129:end, 129:end);
    
    size(inttopleft);
    size(inttopright);
    size(intbtmleft);
    size(intbtmright);
    
    %find brightest corner in intensity image
    %not working because brightest pixels are on edge?? \
    
    intcornersums = [nnz(inttopleft), nnz(inttopright), nnz(intbtmleft), nnz(intbtmright)];
    
    [M,I] = min(intcornersums, [], 'all', 'linear');
    
    
    if I == 1
        corner = 4;
    elseif I == 2
        corner = 3;
    elseif I == 3
        corner = 2;
    elseif I == 4
        corner = 1;
    else 
        disp("ERROR: something wrong with intcornersums")
    end 
    

    ccv = dlmread(string(strcat(folder, '\',ccvlist(num))));
    chi = dlmread(string(strcat(folder, '\',chilist(num))));
    
    %SELECT CROP
    %assuming max bin of 10, move 21 pixels away from the edges
    if corner == 1
        cornerint = intensity(22:122,22:122);
        cornerchi = chi(22:122,22:122);
        cornerccv = ccv(22:122,22:122);
        r = [22 22 100 100];
        
        
    elseif corner == 2 
        cornerint = intensity(22:122,135:235);
        cornerchi = chi(22:122,135:235);
        cornerccv = ccv(22:122,135:235);
        r = [135 22 100 100];
        
    elseif corner == 3
        cornerint = intensity(135:235,22:122);
        cornerchi = chi(135:235,22:122);
        cornerccv = ccv(135:235,22:122);
        r = [22 135 100 100];
        
    elseif corner == 4
        cornerint = intensity(135:235, 135:235);
        cornerchi = chi(135:235, 135:235);
        cornerccv = ccv(135:235, 135:235);
        r = [135 135 100 100];
                
    else 
        disp("ERROR: Issue with selecting brightest corner")
    end
    
    
    boximg = cornerint;       %sanity check for box location??

    if imdis == 1

        figure()
        subplot(2,3,1)
        imshow(intensity)
        rectangle('Position', r , 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle','-');
        axis on;
    
        title('intensity')
        subplot(2,3,2) 
        imshow(chi)
        title('chi')
        subplot(2,3,3) 
        imshow(ccv)
        title('ccv')
        subplot(2,3,4) 
        imshow(cornerchi)
        title('cornerchi')
        subplot(2,3,5)
        imshow(cornerccv)
        title('cornerccv')
        subplot(2,3,6)
        imshow(boximg)
        title(strcat('boximage: TL 1, TR 2, BL 3, BL 4: I =', string(corner)))
    else
        disp("doyouwantimages = 0, no images displayed")
    end 
    
    
    %get nonzero pixel values from cropped image to use for statistics
    
    ccvals = nonzeros(cornerccv);
    chivals = nonzeros(cornerchi);
    intvals = nonzeros(cornerint);
    
    %remove outliers in tm values
    ccvals(ccvals > 8000) = [];
    %size(cornerccv)
    %size(ccvals)
    
    %calculate statistics for each file type
    imgmean = mean(ccvals,'all');  %check for single value
    imgmedian = median(ccvals,'all');
    standarddev = std(ccvals,0, 'all');        % w = 0 to normalize by N-1 (default option)
    cov = standarddev/imgmean;
    
    chimean = mean(chivals, 'all');
    chimedian = median(chivals, 'all');
    chistandarddev = std(chivals, 0, 'all');     % w = 0 to normalize by N-1 (default option)
    
    intmean = mean(intvals, 'all');
    intmedian = median(intvals,'all');
    intstandarddev = std(intvals,0,'all');

    out(num,:) = {ccvlist(num), chilist(num), intensitylist(num), laserclassification(num), cov, imgmean, imgmedian, standarddev, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev};
    disp('function used: statsfromcrop')

end 
out
end 


