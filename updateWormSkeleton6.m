function updated_matrix = updateWormSkeleton6(binary_matrix)
    [m, n] = size(binary_matrix);
    updated_matrix = binary_matrix; % Initialize the updated matrix

    % Iterate through the binary matrix
    for i = m-1:-1:2
        for j = n-1:-1:2
            % Check if the current element is 1
            if binary_matrix(i, j) == 1
                % Extract the 3x3 sub-matrix centered around the current element
                sub_matrix = binary_matrix(i-1:i+1, j-1:j+1);
                % Count the number of elements with value 1 in the sub-matrix
                num_ones = sum(sub_matrix(:)) - 1; % Exclude the center element

                % If the count is greater than 3 and the center element has 0 right above and right below it
                if num_ones > 2 && binary_matrix(i, j-1) == 0 && binary_matrix(i, j+1) == 0
                    % Update the center element to 0
                    updated_matrix(i, j) = 0;
                end
            end
        end
    end
end