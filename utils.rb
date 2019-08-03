def getNode(n,child_name)
	path_parts = child_name.split(":")
	path = path_parts.shift
	new_child_name = path_parts.join(":")

	n.children.each{|child|
		if child.name == path
			if child.name == child_name
				return child
			else
				return getNode(child,new_child_name)
			end
		end
	}

	return nil
end

def getNodes(n,child_name)
	path_parts = child_name.split(":")
	path = path_parts.shift
	new_child_name = path_parts.join(":")

	ret = []

	n.children.each{|child|
		if child.name == path
			if child.name == child_name
				ret << child
			else
				ret << getNode(child,new_child_name)
			end
		end
	}

	return ret
end

def getNodeValue(n,child_name,dict=false)
	node = getNode(n,child_name)
	if node.nil?
		return nil
	end
	if !dict
		return node.values
	else
		ret = {}
		node.children.each{|child|
			ret[child.name] = child.values
		}
		return ret
	end
end

def printTree(n,tabs)
	if n.values.count > 1
		valStr = " --> [" + n.values.join(", ") + "]"
	elsif n.values.count == 1
		valStr = " --> " + n.values[0]
	else
		valStr = ""
	end

	#ap n.attributes
	if n.attributes.count > 0
		nattrs = []
		n.attributes.each{|k,v|
			nattrs << "#{k}:#{v}"
		}
		attStr = " @ [" + nattrs.join(", ") + "]"
	else
		attStr = ""
	end

	puts tabs + n.namespace + ":" + n.name + valStr + attStr

	if n.children.count>0
		n.children.each{|child|
			printTree(child,tabs+"\t")
		}
	end
end