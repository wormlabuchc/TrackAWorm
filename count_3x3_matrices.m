function num_matrices = count_3x3_matrices(binary_matrix)
    [m, n] = size(binary_matrix);
    num_matrices = 0;

    for i = 2:m-1
        for j = 2:n-1
            % Check if current element is 1
            if binary_matrix(i, j) == 1
                % Check the 3x3 matrix centered around the current element
                sub_matrix = binary_matrix(i-1:i+1, j-1:j+1);
                % Check if all elements in the sub-matrix are 1
                if all(sub_matrix(:))
                    num_matrices = num_matrices + 1;
                end
            end
        end
    end
end


