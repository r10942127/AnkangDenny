% BCCH decode
function Decode_symbols = label_code_7(target_constellations,pilot) %每次只丟1~2個burst input, pilot需跟frame一樣長

% target_constellations = rsmoothhhh;
target_constellations_floatindex = angle(target_constellations)*4/pi+4;
if mod(length(target_constellations_floatindex),2) ~= 0
    target_constellations_floatindex = [target_constellations_floatindex 0];
end
tmp = reshape(target_constellations_floatindex,2,[]);

type_1_1 = round(tmp(1,:)/2+0.5)*2-1;
type_1_2 = round(tmp(2,:)/2);
type_1_2(type_1_2==0)=4;
type_1_2 = 2*type_1_2;
type_1 = reshape([type_1_1; type_1_2],1,[]);

clear type_1_1 type_1_2

type_2_1 = round(tmp(1,:)/2);
type_2_1(type_2_1==0)=4;
type_2_1 = 2*type_2_1;
type_2_2 = round(tmp(2,:)/2+0.5)*2-1;
type_2 = reshape([type_2_1; type_2_2],1,[]);

clear type_2_1 type_2_2 tmp

error1 = abs(type_1-target_constellations_floatindex);
error1(error1>7) = 8 - error1(error1>7);
RMSE1 = norm(error1);
error2 = abs(type_2-target_constellations_floatindex);
error2(error2>7) = 8 - error2(error2>7);
RMSE2 = norm(error2);
if RMSE1 >= RMSE2
    target_constellations_index = ceil((mod(type_2+fliplr(1:length(type_2)),8)+1)/2);
else
    target_constellations_index = ceil((mod(type_1+fliplr(1:length(type_1)),8)+1)/2);
end

clear tmp type_1 type_2 target_constellations_floatindex

a = [-1 -1 1 1;-1 1 1 -1];

mapping = perms([1 2 3 4]);

Decode_symbols = [];

for i = 1:24

    map = mapping(i,:);

    data_map = zeros(2,4);
    data_map(:,map == 1) = a(:,1); 
    data_map(:,map == 2) = a(:,2); 
    data_map(:,map == 3) = a(:,3); 
    data_map(:,map == 4) = a(:,4);

    tmp = target_constellations_index;
    tmp2 = zeros(2,length(tmp));
    tmp2(:,tmp==1) = repmat(data_map(:,1),1,length(find(tmp==1)));
    tmp2(:,tmp==2) = repmat(data_map(:,2),1,length(find(tmp==2)));
    tmp2(:,tmp==3) = repmat(data_map(:,3),1,length(find(tmp==3)));
    tmp2(:,tmp==4) = repmat(data_map(:,4),1,length(find(tmp==4)));
    tmp2 = reshape(tmp2,1,[]);

    find_pilot = conv(tmp2,fliplr(pilot));
    find_pilot = find_pilot(length(pilot):end);

    if ~isempty(find(find_pilot>=(length(find(pilot~=0))-7),1))
        q = find(find_pilot>=length(find(pilot~=0))-7);
        qq = [];
        for j = 1:length(q)
            qq = [qq q(j):q(j)+length(pilot)-1];
        end
        Decode_symbols = [Decode_symbols tmp2(qq)];
        return
    end 

    clear tmp1 tmp2

end
% 
% if isempty(Decode_symbols)
%     Decode_symbols = zeros(1,length(pilot));
% end

end



