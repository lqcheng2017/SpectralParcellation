function [MatM,Inlist,CorMat] = MergeConnectivityMatrix2(Seeds,Clusters,Mat,Inc)

% % Merge the tractography matrix according to a given parcellation

%%%%%% INPUTS %%%%%%
% % Seeds: 1xNparcels, list of parcel centers ([1:Nparcels] if there are no centers)
% % Clusters: Nverticesx1, parcel assignment of each vertex
% % Mat: NverticesxNvertices, tractography matrix 
% % Inc: lists the vertices that do not belong to the medial wall

%%%%%% OUTPUTS %%%%%%
% % MatM: NparcelsxNparcels Merged connectivity matrix
% % Inlist: cell array Nverticesx1, list of vertices within a given parcel
% % CorMat: Correlation Matrix of MatM

% Copyright (C) Sarah Parisot, Imperial College London, 2015
%
%This program is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program.  If not, see <http://www.gnu.org/licenses/>.


%% list which vertices belong to which parcels

[a,b]=sort(Seeds);
Nseeds=numel(Seeds);
Inlist=cell(1,Nseeds);
for i=1:Nseeds
    center=Seeds(i);
    Incell1=find(Clusters==Seeds(i));%
   Inlist{i} = Incell1;
end

%% Merging vertices along the row: max value

Mat1=spalloc(numel(Inc),Nseeds,70000000);
tic
for i=1:Nseeds
    N=numel(Inlist{(i)});
    if N==0
        continue
    else
        vec=max((Mat(:,Inlist{(i)})),[],2);  %% only w/ Mat=Mat(Inc,Inc)
        Mat1(:,i)=vec;
    end
end
toc

%% Merging vertices along the column: sum 
Mat1=Mat1';
tic
MatM=spalloc(Nseeds,Nseeds,Nseeds*Nseeds);
for i=1:Nseeds
    N=numel(Inlist{(i)});
    if N==0
        continue
    else
        vec=sum((Mat1(:,Inlist{(i)})),2);
        MatM(:,i)=vec; 
    end
end
toc

MatM = full(MatM);

%% Compute the correlation matrix

if nargout==3
    MatM(MatM<1)=0;
    Matlog=log(MatM);
    Matlog(Matlog<0)=0;
    CorMat=corrcoef(Matlog);
end

MatM=MatM/5000; % 5000: number of streamlines sent through probtrackX
