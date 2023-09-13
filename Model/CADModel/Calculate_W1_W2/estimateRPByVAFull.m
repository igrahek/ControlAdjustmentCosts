function [R,P] = estimateRPByVAFull(driftrate,threshold,NDT,costFunc,costFuncDeva,costFuncDevv,grid)

% Caluclate reward and penalty from drift rate and threshold
if grid == 1
    
    a_mat = repmat(threshold',1,length(driftrate));

    v_mat = repmat(driftrate,length(threshold),1);
    
    a = a_mat(:);

    v = v_mat(:);
    
    
else
    
    v = driftrate;
    
    a = threshold;
end

dDT_dv = - a./(v.^2).*tanh(a.*v) + a./v.*(1-tanh(a.*v).^2).*a;

dDT_da = 1./v.*tanh(a.*v) + a./v.*(1-tanh(a.*v).^2) .*v;

dER_dv = -1./(1 + exp(2.*a.*v)).^2.*exp(2.*a.*v).*2.*a;

dER_da = -1./(1 + exp(2.*a.*v)).^2.*exp(2.*a.*v).*2.*v;

DT = a./v.*tanh(a.*v);

ER = 1./(1 + exp(2*a.*v));

C_a_R = ((1-ER).*dDT_da+(DT+NDT).*dER_da)./(DT + NDT).^2;

C_a_P = ((DT+NDT).*dER_da - ER.* dDT_da)./(DT + NDT).^2;

C_v_R = ((1-ER).*dDT_dv+(DT+NDT).*dER_dv)./(DT + NDT).^2;

C_v_P = ((DT+NDT).*dER_dv - ER.* dDT_dv)./(DT + NDT).^2;

if grid == 1

    comat(1,1,:) = C_a_R;

    comat(1,2,:) = C_a_P;

    comat(2,1,:) = C_v_R;

    comat(2,2,:) = C_v_P;

    invmat = multinv(comat);

    constant1 = -costFuncDeva(v,a);
    
    constant2 = -costFuncDevv(v,a);

    R = squeeze(invmat(1,1,:)).*constant1 + squeeze(invmat(1,2,:)).*constant2;

    P = squeeze(invmat(2,1,:)).*constant1 + squeeze(invmat(2,2,:)).*constant2;

    RR = (R .* (1-ER) - P .* ER)./(DT + NDT) - costFunc(v,a);

%     R(RR<0) = nan;
% 
%     P(RR<0) = nan;
%     
    R = reshape(R,size(a_mat));
%     
    P = reshape(P,size(a_mat));

else
    
    comat = [C_a_R C_a_P;C_v_R C_v_P];
    
    constant = [-costFuncDeva(v,a);-costFuncDevv(v,a)];
    
    weights = comat \ constant;
    
    R = weights(1);
    
    P = weights(2);
    
    RR = (R .* (1-ER) - P .* ER)./(DT + NDT) - costFunc(v,a);

%     if RR < 0
%         
%         R = nan;
%         
%         P = nan;
%         
%     end  
%     
end


end