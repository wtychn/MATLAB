clc
close all
clear
%����������
clear all;
clc;
avi=VideoReader('move.avi');
VidFrames=read(avi,[85,250]);
N=100;                                            
start=11;                                        
threshold=15;
bg(start).cdata=0;
i=1;
for k=start-10:start-1
    bg(k).cdata=rgb2gray(VidFrames(:,:,:,k));
    bg(start).cdata=abs((bg(start).cdata+bg(k).cdata)/i); %��ֵ����������
    i=i+1;
end
for k=1+start:N+1+start                                            
    mov(k).cdata=rgb2gray(VidFrames(:,:,:,k)); %ת���ɻҶ�ͼ    
end
[row,col]=size(mov(1+start).cdata);            

alldiff=zeros(row,col,N); 
bgpic=zeros(row,col,1);
bgdata=bg(start).cdata>threshold;
bgpic(:,:,1)=double(bgdata);  
figure(1);
imshow(bgpic(:,:,1))   %��������ı���

for k=1+start:N+start
    diff=abs(mov(k).cdata-bg(start).cdata);       %ԭͼ���ȥ����   
    idiff=diff>threshold;                           
    alldiff(:,:,k)=~double(idiff);
    
    stats = regionprops(alldiff(:,:,k), 'basic');
    areaArray =[stats. Area];
    [junk, idx] = max(areaArray);
%     c = stats(idx). Centroid;
    c = cat(1,stats. Centroid);
    c = floor(fliplr(c));
    width = 5;
    row=zeros(size(c, 1),1+2*width);
    col=zeros(size(c, 1),1+2*width);
    for i = 1:size(c, 1)
        row(i,:) = c(i,1)- width:c(i,1) + width;     %�˶�Ŀ����
        col(i,:) = c(i,2)- width:c(i,2) + width;
        VidFrames(row(i,:),col(i,:),1,k) = 255;
        VidFrames(row(i,:),col(i,:),2,k) = 0;
        VidFrames(row(i,:),col(i,:),3,k) = 0;
    end
end

implay(VidFrames)