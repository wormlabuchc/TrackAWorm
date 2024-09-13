function xOut=linInterp(x1,x2,n)

dx=abs((x2-x1)/(n-1));
if x1==x2
    xOut=ones(1,n);
    xOut=xOut*x1;
else

    if x1<x2
        xOut=x1:dx:x2;
    elseif x2<x1
        xOut=x2:dx:x1;
        xOut=fliplr(xOut);
    end
end

if n~=length(xOut)
    disp('n does not match xOut')
end