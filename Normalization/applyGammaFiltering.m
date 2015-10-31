function imageGammaFiltered = applyGammaFiltering(hObject, image)
    %This function will remove the gamma from the image
    % FIXME! Needs to have a concrete input type
    %handles = guidata(hObject);
    if (get(handles.checkboxGammaFilteringFlag,'value') == 1)
        filter = ones(9);
        imageGammaFiltered = imfilter(image, filter, 'replicate', 'same', 'corr');
    else
        imageGammaFiltered = image;
    end
    
end
