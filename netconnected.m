function [con,nn] = netconnected(matnet)
% are all nodes in the network connected?
maxpow = 200;
jmppow = 50;
maxjmp = 50;
len = length(matnet);
pownum = min(len-1,maxpow);  % too computationaly heavy otherwise 
% add a diagonal, take to the power of N-1

nn  = logical((logical(matnet)+eye(len))^pownum);
if(pownum==maxpow) % use an iterative approach if the network is too large...
    grps = unique(sum(nn));
    oldsum = sum(grps)+1;
    newsum = oldsum-1;
    jmp  = 1;
    while(jmp<maxjmp) && (newsum<oldsum)
    %if(length(grps)>3) && (grps(end-1)>(len-grps(end)))
        %if(sum(sum(isnan(nn^pownum)))) imagesc(nn^1); disp(sum(sum(isnan(nn^1)))); pause;imagesc(nn^100); disp(sum(sum(isnan(nn^100)))); pause;imagesc(nn^200); disp(sum(sum(isnan(nn^200)))); pause; imagesc(nn^400); disp(sum(sum(isnan(nn^400)))); pause; end;
        nn = logical(nn^jmppow);
        grps = unique(sum(nn));
        oldsum = newsum;
        newsum = sum(grps);
        jmp=jmp+1;
        
        %disp([888 jmp jmppow oldsum newsum]);
        %hist(sum(nn),20); pause;
    end;
    %if(length(grps)>3) disp([999 length(grps) grps(end-1) (len-grps(end))]); end;
end;
% check that there are no zeros at all
con = (nnz(nn) == (len^2));

end
