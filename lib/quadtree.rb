class QuadTree 
  attr_accessor :root 
  def initialize(longitude, latitude)
    @root = QuadTreeNode.new(longitude, latitude, nil, nil)
  end 

  def add_node(longitude, latitude, location_id) 
    leaf = QuadTreeNode.new(longitude, latitude, location_id, nil)
    insert_helper(@root, leaf)
  end

  private

  def insert_helper(current_node, node_to_insert) 
    puts "insert helper called with current_node = #{current_node} and node_to_insert = #{node_to_insert}"
    direction = get_direction(current_node, node_to_insert)
    if current_node.children[direction].nil?
      insert_at_node(current_node, node_to_insert, direction)
    elsif current_node.children[direction].is_leaf? 
      #direction leads to a leaf. create a non-leaf node in place of the leaf and then insert both 
      #node_to_insert and the leaf into the tree 
      conflicting_leaf = current_node.children[direction]
      average_of_leaf_long = (node_to_insert.longitude + conflicting_leaf.longitude)/2
      average_of_leaf_lat = (node_to_insert.latitude + conflicting_leaf.latitude)/2
      non_leaf_node = QuadTreeNode.new(average_of_leaf_long, average_of_leaf_lat, nil, current_node)
      current_node.children[direction] = non_leaf_node
      reduce_num_leaves_by_one(current_node)
      insert_helper(non_leaf_node, node_to_insert)
      insert_helper(non_leaf_node, conflicting_leaf)
      #new non-leaf will be created in the 'middle' of the direction's quadrant 
    else 
      insert_helper(current_node.children[direction], current_node)
    end
  end  

  def insert_at_node(current_node, node_to_insert, direction)
    node_to_insert.parent = current_node
    current_node.children[direction] = node_to_insert
    increase_num_leaves_by_one(current_node)
  end

  def reduce_num_leaves_by_one(node) 
    while(!node.nil?)
      puts "decreasing leavs by 1 "
      node.total_leaves -= 1 
      node = node.parent 
    end 
  end 

  def increase_num_leaves_by_one(node)
    while(!node.nil?)
      puts "increasing leavs by 1 "
      node.total_leaves += 1 
      node = node.parent 
    end 
  end

  def get_direction(current_node, node_to_insert)
    # return the index of the children array of the current node that the node to insert should be in 
    if node_to_insert.longitude >= current_node.longitude
      if node_to_insert.latitude >= current_node.latitude
        0 
      else 
        3 
      end
    else
      if node_to_insert.latitude >= current_node.latitude 
        1
      else 
        2 
      end 
    end
  end 


end

class QuadTreeNode 
  attr_accessor :longitude, :latitude, :location_id, :children, :total_leaves, :parent
  ###
  # children is an array of length 4 representing the child nodes of the node. 
  # index 0 is north-east (higher long and lat), 1 is south east, 2 is south west, 3 is north west 
  ###
  def initialize(longitude, latitude, location_id, parent)
    @longitude = longitude
    @latitude = latitude
    @location_id = location_id
    @parent = parent
    @children = [nil,nil,nil,nil]
    @total_leaves = if location_id.nil? then 0 else 1 end
  end

  def is_leaf? 
    !location_id.nil?
  end


end 