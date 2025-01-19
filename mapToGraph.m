function theGraph = mapToGraph(gardenMap)
% create node table to ensure that nodes without edges (area = 1) are accounted for
nPoints = numel(gardenMap);
nodeTable = table();
nodeTable.letter = gardenMap(:);
[nodeRows,nodeCols] = ind2sub(size(gardenMap),1:nPoints);
nodeTable.iRow = nodeRows(:);
nodeTable.iCol = nodeCols(:);

edgeTable = table();
edgeTable.EndNodes = nan(2*nPoints,2);
mapWidth = width(gardenMap);
mapHeight = height(gardenMap);
iNode = 0;
iEdge = 0;
for iWidth = 1:mapWidth
    for iHeight = 1:mapHeight
        % only need to search down and right
        letter = gardenMap(iHeight,iWidth);
        iNode = iNode + 1;

        if iHeight < mapHeight && gardenMap(iHeight+1,iWidth) == letter
            iNodeDown = iNode + 1;
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeDown];
        end

        if iWidth < mapWidth && gardenMap(iHeight,iWidth+1) == letter
            iNodeRight = sub2ind([mapHeight,mapWidth],iHeight,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeRight];
        end
    end
end
edgeTable = edgeTable(~any(isnan(edgeTable.EndNodes),2),:);
theGraph = graph(edgeTable,nodeTable);
end