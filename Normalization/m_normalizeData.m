function m_normalizeData(hObject)
    %this will run the normalization

    % The problem with this function is that hObject is dynamically constructed 
    % from the gui. The good thing is that the next few lines that are commented
    % out can be moved to a preprocessing function and arguments with concrete
    % types can be passed into this function instead. 

    % We also cannot use cell arrays if we use MATLAB coder.

    % After that, this function will convert fine as long as all of the
    % functions it calls are also in the conversion process. Thus we need to 
    % make sure those functions can be converted first, their dependencies too,
    % etc. 
    
    % FIXME! Print to logger instead
    % message = sprintf('Running normalization ...');
    %statusBarMessage(hObject, message, 0, false);
    
    % FIXME! Pass concrete type
    %handles = guidata(hObject);    
    %ask where to create the normalized data folder
    %path = handles.path;
    % FIXME! Pass file names into the function! Don't retrieve them here!
    % outside it.
    %folderName = uigetdir(path, 'Where do you want to create the Normalized data folder?');
    %if folderName == 0
    %    return %we did not select a folder
    %end
    
    %folderName = [folderName '/Normalized'];
    %[~, ~] = mkdir(folderName);
    
    %listDataFiles = handles.files.fileNames;
    %nbrFiles = numel(listDataFiles);
    
    [roiLogicalArray, isWithRoi] = getRoiLogicalArray(hObject);
    
    %take average of all open beam
    averageTotalOpenBeam = getAverageArray(hObject, 'OB');
    if isWithRoi
        averageRoiOpenBeam = getAverageOfRoi(averageTotalOpenBeam, roiLogicalArray);
    end
    
    %take average of all dark field
    averageTotalDarkField = getAverageArray(hObject, 'DF');
    data = handles.files.images;
    
    for i=1:nbrFiles
     
        %Don't use cell arrays
    %    tmpData = data{i};
        tmpDataFiltered = applyGammaFiltering(hObject, tmpData);
        
        imshow(tmpDataFiltered,[]);
        colorbar;
        
        if isWithRoi
            averageTmpData = getAverageOfRoi(tmpDataFiltered, roiLogicalArray);
            ratio = averageTmpData / averageRoiOpenBeam;
            tmpDataFiltered = tmpDataFiltered / ratio;
        end
        
        topRatio = tmpDataFiltered - averageTotalDarkField;
        bottomRatio = averageTotalOpenBeam - averageTotalDarkField;
        
        normalizedImage = topRatio ./ bottomRatio;
        
        %bring to zero all the counts < 0
        lessThanZero = normalizedImage < 0;
        normalizedImage(lessThanZero) = 0;
        
        %bring to 1 all the counts > 1
        moreThanOne = normalizedImage > 1;
        normalizedImage(moreThanOne) = 1;
        
        %normalizedImage = cast(normalizedImage,'int16');
        
        createNormalizedFile(normalizedImage, folderName, listDataFiles{i});
        
    end
    
    message = sprintf('Normalization is Done !');
    statusBarMessage(hObject, message, 5, false);
    
end

function createNormalizedFile(data, folder, fileName)
    %this routine will create the output normalized file in the folder
    %specified
    
    [path, name, ~] = fileparts(fileName);
    fileName = fullfile(path, [name, '.fits']);
    
    fullFileName = [folder '/' fileName];
    %    imwrite(data,fullFileName,'tif');
    % data = im2int16(data);
    fitswrite(data, fullFileName);
    
end

