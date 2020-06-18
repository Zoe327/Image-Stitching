function [model, inliers] = RANSAC(tuples, iterations, thres)
    %input  4-tuple: (xi, yi, xi', yi')
    % output  H, Consensus set(inliers 
    
    inliers = [];
    for i = 1:iterations
        %Randomly choose a feature pair 
        idx = randperm(size(tuples, 1), 4);
        tuple = tuples(idx', :);
        
        %Solve for Homography Hi
        [A, ~] = solveHomo(tuple, 4);
        H_vec = null(A'*A);
        if size(H_vec,2) > 1
            continue
        end        
        H = [H_vec(1:3)';H_vec(4:6)';H_vec(7:9)'];
        
        % CONSESUS ALGORITHM 
        tuples_left = tuples;
        tuples_left(idx', :) = [];
        consensus = [];
        for j = 1:size(tuples_left,1)
            tuple_compare = tuples_left(j,:);
            % fit the feature with homography
            xy = tuple_compare(1:2)';
            true = tuple_compare(3:4)';
            pred = H * [xy;1];
            xy_n = pred(1:2)/pred(3);
            dist = norm(true - xy_n);
            
            %The best model is the model that have the largest number of
            %consensus points.
            if dist <= thres
                consensus = [consensus; tuple_compare];
            end
        end

        if size(consensus,1) > size(inliers,1)
            inliers = consensus;
        end
    end
    
    %Re-estimate a homography H using least squares
    [A, ~] = solveHomo(inliers, size(inliers,1));
    %[eigVectors, ~, ~] = eig(A'*A);
    %eigVectors = null(A'*A);
    [eigVectors, ~] = eigs(A'*A,1,'smallestabs');
    model_vec = eigVectors(:,1);
    model = [model_vec(1:3)';model_vec(4:6)';model_vec(7:9)'];
    
end