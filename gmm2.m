clc;
clear all; 
cntFrame = 100;
obj = VideoReader('move2.avi');
numFrames = obj.NumberOfFrames;
%  for k = 1 : cntFrame
%      frame = read(obj,k);
%       imwrite(frame,...
%           strcat('D:\WTYdoc\MATLAB\graduate\video\',...
%           num2str(k),'.bmp'),'bmp');
%  end
%% �������弰��ʼ��
I = imread('1.bmp');                    %�����һ֡��Ϊ����֡
fr_bw = I;     
[height,width] = size(fr_bw);           %��ÿ֡ͼ���С
width = width/3;                        %�ų���ɫͨ����
fg = zeros(height, width);              %����ǰ���ͱ�������
bg_bw = zeros(height, width);
 
C = 3;                                  % ����˹ģ�͵ĸ���(ͨ��Ϊ3-5)
M = 3;                                  % ����������ģ�͸���
D = 1;                                % ƫ����ֵ
alpha = 0.01;                           % ѧϰ��
thresh = 0.25;                          % ǰ����ֵ
sd_init = 15;                           % ��ʼ����׼��
w = zeros(height,width,C);              % ��ʼ��Ȩ�ؾ���
mean = zeros(height,width,C);           % ���ؾ�ֵ
sd = zeros(height,width,C);             % ���ر�׼��
u_diff = zeros(height,width,C);         % ������ĳ����˹ģ�;�ֵ�ľ��Ծ���
p = alpha/(1/C);                        % ��ʼ��p�������������¾�ֵ�ͱ�׼��
rank = zeros(1,C);                      % ������˹�ֲ������ȼ���w/sd)
 
pixel_depth = 8;                        % ÿ������8bit�ֱ���
pixel_range = 2^pixel_depth -1;         % ����ֵ��Χ[0,255]
 
for i=1:height
    for j=1:width
        for k=1:C
            mean(i,j,k) = rand*pixel_range;     %��ʼ����k����˹�ֲ��ľ�ֵ
            w(i,j,k) = 1/C;                     % ��ʼ����k����˹�ֲ���Ȩ��
            sd(i,j,k) = sd_init;                % ��ʼ����k����˹�ֲ��ı�׼��           
        end
    end
end
 
for n = 1:3:cntFrame
    frame=strcat(num2str(n),'.bmp');
    I1 = imread(frame);  % ���ζ����֡ͼ��
    fr_bw = I1;       
    % �������������m����˹ģ�;�ֵ�ľ��Ծ���
    for m=1:C
        u_diff(:,:,m) = abs(double(fr_bw(:,:,m)) - double(mean(:,:,m)));
    end
    % ���¸�˹ģ�͵Ĳ���
    for i=1:height
        for j=1:width
            match = 0;                                       %ƥ����;
            for k=1:C                       
                if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % �������k����˹ģ��ƥ��  
                    match = 1;                               %��ƥ������Ϊ1
                    % ����Ȩ�ء���ֵ����׼�p
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;
                    p = alpha/w(i,j,k);                  
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);
                else                                         % �������k����˹ģ�Ͳ�ƥ��
                    w(i,j,k) = (1-alpha)*w(i,j,k);           %��΢����Ȩ��   
                end
            end      
            bg_bw(i,j)=0;
            for k=1:C
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);
            end
            % ����ֵ����һ��˹ģ�Ͷ���ƥ�䣬�򴴽��µ�ģ��
            if (match == 0)
                [min_w, min_w_index] = min(w(i,j,:));      %Ѱ����СȨ��
                mean(i,j,min_w_index) = double(fr_bw(i,j));%��ʼ����ֵΪ��ǰ�۲����صľ�ֵ
                sd(i,j,min_w_index) = sd_init;             %��ʼ����׼��Ϊ6
            end
            rank = w(i,j,:)./sd(i,j,:);                    % ����ģ�����ȼ�
            rank_ind = (1:1:C);%���ȼ�����       
            % ����ǰ��      
            fg(i,j) = 0;
            while ((match == 0)&&(k<=M))         
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))% �������k����˹ģ��ƥ��
                        fg(i,j) = 0; %������Ϊ��������Ϊ��ɫ        
                    else
                        fg(i,j) = 255;    %����Ϊǰ������Ϊ��ɫ 
                    end                        
                k = k+1;
            end
        end
    end
    
    T=graythresh(fg);
    fg_bw=im2bw(fg,T);
    erodeElement = strel('square',1) ;
    dilateElement=strel('square',4) ;
    fg_bw=imerode(fg_bw,erodeElement);
    fg_bw=imdilate(fg_bw,dilateElement);
    fg_bw=imfill(fg_bw,'holes');
    fg_reg=regionprops(fg_bw,'area','boundingbox');
    areas=[fg_reg.Area];
    rects=cat(1,fg_reg.BoundingBox);
    
    figure(n)
    subplot(1,3,1),imshow(fr_bw);               %��ʾ���һ֡ͼ��
    for i=1:size(rects,1)
        if(rects(i,3)>50&&rects(i,4)>60)
            rectangle('position',rects(i,:),'EdgeColor','r');
        end
    end
    subplot(1,3,2),imshow(uint8(bg_bw))         %��ʾ����
    subplot(1,3,3),imshow(fg_bw);   %��ʾǰ��
end