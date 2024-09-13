function cont = find_head(rawimg)
    img = imadjust(rawimg);
    img = imcomplement(img);
    img = imfill(img,8,'holes');
    img = imbinarize(img);
    img = bwareafilt(img,1);
    contarray = contourc(double(img),1);
    % [cont,sidesno] = convertcontour(C);
    %%
    lineCol = contarray(2,1);
    contarray = contarray(:,2:(lineCol+1));
    contx = contarray(1,:);
    conty = contarray(2,:);
    [Xmin,Xminidx] = min(contx);
    [Xmax,Xmaxidx] = max(contx);
    [Ymin,Yminidx] = min(conty);
    [Ymax, Ymaxidx] = max(conty);
    Y_Xmax = conty(Xmaxidx);
    X_Ymax = contx(Ymaxidx);
    X_Ymin = contx(Yminidx);
    Y_Xmin = conty(Xminidx);

    sideno =1;
    if Xmin<20
        sideno =1;
        dataidx = find(contx<20);
        contarray(:,dataidx) = [];
        if Ymin<20
            luidx = find(conty<20);
            contarray(:,luidx) = [];
        elseif Ymax >460
             ldidx = find(conty>460);
            contarray(:,ldidx) = [];           
        else
        end
    elseif Ymin<20
        sideno = 2;
        dataidx = find(contarray(2,:)<20);
        contarray(:,dataidx) = [];
         if Xmin<20
            luidx = find(contx<20);
            contarray(:,luidx) = [];
        elseif Xmax >460
             ruidx = find(contx>460);
            contarray(:,ruidx) = [];           
        else
        end       
    elseif Xmax>460
        sideno = 3;
        dataidx = find(contarray(1,:)>460);
        contarray(:,dataidx) = [];
        if Ymin<20
            ruidx = find(conty<20);
            contarray(:,ruidx) = [];
        elseif Ymax >460
             rdidx = find(conty>460);
            contarray(:,rdidx) = [];           
        else
        end        
    elseif Ymax>460
        sideno = 4;
        dataidx = find(contarray(2,:)>460);
        contarray(:,dataidx) = [];
        if Xmin<20
            ldidx = find(contx<20);
            contarray(:,ldidx) = [];
        elseif Xmax >460
             rdidx = find(contx>460);
            contarray(:,rdidx) = [];           
        else
        end        
    end
    cont.Xmin = Xmin;
    cont.Xminidx = Xminidx;
    cont.Xmax = Xmax;
    cont.Xmaxidx = Xmaxidx;
    cont.Ymin = Ymin;
    cont.Yminidx = Yminidx;
    cont.Ymax = Ymax;
    cont.Ymaxidx = Ymaxidx;
    cont.Y_Xmax = Y_Xmax;
    cont.X_Ymax = X_Ymax;
    cont.X_Ymin = X_Ymin;
    cont.Y_Xmin = Y_Xmin;
    cont.array = contarray;
    cont.contx = contx;
    cont.conty = conty;
    cont.sideno = sideno;

end



