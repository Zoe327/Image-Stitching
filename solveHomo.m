function [A,Homography] = solveHomo(points, N)
    % input-- points 4x4 matrix, feature pairs in each row
    %      -- N number of feature pairs 
    % output -- Homography 
    % data matrix A 
    A = zeros(2*N , 9);
    Homography = zeros(3, 3);
    for n = 1: N
        A(2*n-1, 1:2) = points(n, 1:2); 
        A(2*n-1, 3) = 1;
        A(2*n-1, 7) = -points(n, 3)*points(n, 1);
        A(2*n-1, 8) = -points(n, 3)*points(n, 2);
        A(2*n-1, 9) = -points(n, 3);
        
        A(2*n, 4:6) =  A(2*n-1, 1:3);
        A(2*n, 7) = -points(n, 4)*points(n, 1);
        A(2*n, 8) = -points(n, 4)*points(n, 2);
        A(2*n, 9) = -points(n, 4);
    end
end
