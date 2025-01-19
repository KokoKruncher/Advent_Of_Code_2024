function vertexGraph = createVertexGraph(vertexRows,vertexCols)
arguments
    vertexRows (:,1) double
    vertexCols (:,1) double
end

nRowIndx = numel(vertexRows);
nColIndx = numel(vertexCols);
assert(nRowIndx == nColIndx,"Number of row and column indices don't match.")

gridSize = [max(vertexRows), max(vertexCols)];
map = false(gridSize);
iVertex = sub2ind(gridSize,vertexRows,vertexCols);
map(iVertex) = true;

% create node table to ensure that nodes without edges (area = 1) are accounted for
nPoints = numel(map);
nodeTable = table();
[nodeRows,nodeCols] = ind2sub(size(map),1:nPoints);
nodeTable.iRow = nodeRows(:);
nodeTable.iCol = nodeCols(:);

edgeTable = table();
edgeTable.EndNodes = nan(2*nPoints,2);
mapWidth = width(map);
mapHeight = height(map);
iNode = 0;
iEdge = 0;
for iWidth = 1:mapWidth
    for iHeight = 1:mapHeight
        % need to search all 4 directions
        point = map(iHeight,iWidth);
        iNode = iNode + 1;
        if ~point
            continue
        end

        if iHeight > 1 && map(iHeight-1,iWidth)
            iNodeUp = iNode - 1;
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeUp];
        end

        if iHeight < mapHeight && map(iHeight+1,iWidth)
            iNodeDown = iNode + 1;
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeDown];
        end

        if iWidth < mapWidth && map(iHeight,iWidth+1)
            iNodeRight = sub2ind([mapHeight,mapWidth],iHeight,iWidth+1);
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeRight];
        end

        if iWidth > 1 && map(iHeight,iWidth-1)
            iNodeLeft = sub2ind([mapHeight,mapWidth],iHeight,iWidth-1);
            iEdge = iEdge + 1;
            edgeTable{iEdge,:} = [iNode, iNodeLeft];
        end
    end
end
edgeTable = edgeTable(~any(isnan(edgeTable.EndNodes),2),:);
vertexGraph = graph(edgeTable,nodeTable);

% remove edges counted more than once
vertexGraph = simplify(vertexGraph);

% remove nodes that are not a vertex
isVertex = vertexGraph.degree > 1;
nNodes = vertexGraph.numnodes;
allNodeIds = 1:nNodes;
vertexGraph = vertexGraph.rmnode(allNodeIds(~isVertex));
end