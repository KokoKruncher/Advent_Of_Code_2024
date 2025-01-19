clear; clc; close all

%% Part 1
filename = "D12 Data.txt";
% input = readlines(filename);
input = ["RRRRIICCFF"; ...
"RRRRIICCCF"; ...
"VVRRRCCFFF"; ...
"VVRCCCJFFF"; ...
"VVVVCJJCFE"; ...
"VVIVCCJJEE"; ...
"VVIIICJJEE"; ...
"MIIIIIJJEE"; ...
"MIIISIJEEE"; ...
"MMMISSJEEE"];

gardenMap = parseInput(input);

gardenGraph = mapToGraph(gardenMap);

% each node starts off with a perimiter of 4 (1 on each side). every new edge decreases
% its perimeter by 1.
[nodeRegionIndx,regionAreas] = gardenGraph.conncomp;
nRegions = max(nodeRegionIndx);
regionPerimeters = nan(size(regionAreas));
nodeDegrees = gardenGraph.degree();
for iRegion = 1:nRegions
    isNodeInRegion = nodeRegionIndx == iRegion;
    nNodesInRegion = nnz(isNodeInRegion);
    regionPerimeters(iRegion) = sum(4 - nodeDegrees(isNodeInRegion));
end
fencePrices = regionPerimeters.*regionAreas;
totalFencePrice = sum(fencePrices);

fprintf("Total fence price: %i\n",totalFencePrice)

%% Part 2
% get vertex locations for each region and make a graph. side nodes are nodes that have
% degree of exactly 2. graph can have up to 2 components, 1 for outer fence and one for
% inner fence if it exists. DFS each component, add a side when direction changes.

for iRegion = 1:1
    isNodeInRegion = nodeRegionIndx == iRegion;
    regionNodes = gardenGraph.Nodes(isNodeInRegion,:);
    [vertexRows,vertexCols] = gridIndxToVertex(regionNodes.iRow,regionNodes.iCol);
    vertexGraph = createVertexGraph(vertexRows,vertexCols);
    
    % vertices on the side (outside or inside if it exists) have degree less than 4
    isSideVertex = vertexGraph.degree < 4;
    nVertices = vertexGraph.numnodes;
    allVertices = 1:nVertices;
    sideGraph = vertexGraph.rmnode(allVertices(~isSideVertex));
end
figure
x = vertexGraph.Nodes.iCol;
y = vertexGraph.Nodes.iRow;
z = zeros(size(x));
plot(vertexGraph,'XData',x,'YData',y)
%% Functions
function gardenMap = parseInput(input)
gardenMap = split(input,"");
gardenMap = gardenMap(:,2:end-1);
end