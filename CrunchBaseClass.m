classdef CrunchBaseClass
    %Unofficial API for crunchbase.com
    %   
    % Created by Biao Mao, maob@rpi.edu
    
    properties
        baseUrl='http://api.crunchbase.com/v/2/';
        userKey='e9905728189d2e59c5c9e7ee8ad9a170';
        personPath='personInfo.xlsx';
    end
    
    methods
        function obj=CrunchBaseClass()
        	% Construct function
        	% obj.getPeoplelist();
        	load('peopleList');
        	obj.getItems(peopleTable,'advisor_at');
        end

        function getItems(obj,peopleTable,itemType)
        	% Get the Items for each relationship

        	[nPeople, nCols]=size(peopleTable);
            items=cell(nPeople,1);
        	for i=1:nPeople
        		% Get the content from website
        		url=strcat(obj.baseUrl,peopleTable{i,'Path'},'?user_key=',obj.userKey);
        		[str,status]=urlread(url{:});
                if status==0
                    continue;
                end
        		content=loadjson(str);
                
        		% Look for the item in the data.relationships  
        		if isfield(content.data,'relationships')              
	        		relations=content.data.relationships;
	        		if isfield(relations,itemType)
	        			nItems=relations.(itemType).paging.total_items;
	        			strItem='';
	        			for j=1:nItems
	        				selItem=relations.(itemType).items{1,j};
	        				if isempty(selItem.organization_name)
	        					selItem.organization_name='null';
	        				end
	        				strItem=strcat(strItem,selItem.organization_name,':',selItem.title,';');
	        			end
	        			items{i,1}=strItem;
	        		end
	        		% Debug infomation
	        		if mod(i,20)==0
	        			fprintf('%d persons completed\n',i);
	        		end
	        	end
            end
            peopleTable=[peopleTable items];
            peopleTable.Properties.VariableNames{nCols+1}=itemType;
            writetable(peopleTable,obj.personPath);
        end

        function getPeoplelist(obj)
        	% Return a paginated list of all People in CrunchBase
        	
        	opt='&page=1&order=created_at+DESC';
        	fullUrl=strcat(obj.baseUrl,'people?user_key=',obj.userKey,opt);
        	str=urlread(fullUrl);

        	% Save the people list to the file
        	% fName='peopleList.json';
        	% fid=fopen(fName,'w');
        	% if fid~=-1
        	% 	fprintf(fid,'%s\r\n',str);
        	% 	fclose(fid);
        	% end

        	% Load the JSON content
        	pList=loadjson(str);
        	nPeople=length(pList.data.items);
        	peopleInfo=cell(nPeople,2);
        	for i=1:nPeople
        		peopleInfo{i,1}=pList.data.items{1,i}.name;
        		peopleInfo{i,2}=pList.data.items{1,i}.path;
	       	end
	       	peopleTable=table(peopleInfo(:,1),peopleInfo(:,2),'VariableNames',{'Name','Path'});
            save('peopleList','peopleTable');
        end
    end
    
end

