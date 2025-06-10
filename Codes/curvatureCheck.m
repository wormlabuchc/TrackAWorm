function curvatureCheck(mX,mY)

bendAngles = findWormAngles(mX,mY);

if max(abs(bendAngles))>120 || sum(isnan(bendAngles))~=0
    disp('Invalid worm spline curvature; Retrying.')
%     guihgka
end
% delete(f)