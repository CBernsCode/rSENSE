###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###

##########################################################################
# Programmer:   Jacob Kinsman                                            #
#                                                                        #
# Assignment:   Honors Project                                           #
#                                                                        #
# File:         Binary Tree                                              #
#                                                                        #
# Description:  This file defines a modified binary tree that            #
#               will be used to represent prefix expressions in my       #
#               symbolic regression implementation.                      #
##########################################################################


$ ->

  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]
    
    class window.binaryTree

      @terminals = [
        'x', Math.E, Math.PI
      ]

      @operators = [
        (a, b) -> a + b,
        (a, b) -> a - b,
        (a, b) -> a * b,
        (a, b) -> if b is 0 then 1 else a / b,
        (a, b) -> Math.pow(a,b),
        (a)    -> Math.exp(a), 
        (a)    -> Math.cos(a),
        (a)    -> Math.sin(a),
        (a)    -> Math.log(Math.abs(a))
        (a)    -> Math.sqrt(Math.abs(a))
      ]

      constructor: (parent = null) ->
        @data = null
        @right = null
        @left = null
        @parent = parent

      # Returns deep copy of binary tree object
      @clone: (tree, parent = null) ->
        return tree if tree is null or typeof tree isnt 'object'
        temp = new binaryTree(parent)
        for key of tree when (typeof tree[key] isnt 'function' and key isnt 'parent')
          temp[key] = @clone(tree[key], temp)
        temp['data'] = tree.data
        temp

      # Returns true if a and b are equivalent objects 
      # (not necessarily references to the same object in memory).
      @is_equal: (a, b) ->
        recur = false
        if a is null and b is null
          return true
        if Object.keys(a).length == Object.keys(b).length
          for key of a when key isnt 'parent'
            if typeof(a[key]) is 'object'
              recur = @is_equal(a[key], b[key])
            else if a[key] != b[key]
              return false
        recur

      # Checks if the tree is terminal (i.e., no children)
      is_terminal: ->
        @left is null and @right is null

      # Returns number of nodes in the tree
      treeSize: ->
        rest = 0
        if @right isnt null
          rest += @right.treeSize()
        if @left isnt null
          rest += @left.treeSize()
        1 + rest

      # Returns the maximum depth of the tree
      maxDepth: ->
        rest = 0
        if @left isnt null
          rest = Math.max(rest, @left.maxDepth())
        if @right isnt null
          rest = Math.max(rest, @right.maxDepth())
        1 + rest

      # Inserts a single datum in the tree at @data, 
      # or the @data member of the tree located at 
      # pos = 'left' or pos = 'right'
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      insertData: (data, pos = null) ->
        if pos is 'left'
          if @data isnt null
            if @left is null
              @left = new binaryTree(this)
              @left.data = data

          else
            console.log "Error inserting #{data} into left child of tree."
        else if pos is 'right'
          if @data isnt null
            if @right is null
              @right = new binaryTree(this)
              @right.data = data
          else
            console.log "Error inserting #{data} into right child of tree."
        else
          @data = data

      # Delete a single datum in the tree at @data,
      # or the @data member of the tree located at 
      # pos = 'left' or pos = 'right'
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      deleteData: (pos = null) ->
        if pos is 'right'
          if @right.is_terminal()
            @right = null 
          else
            console.log "Error deleting #{@right.data}, results in invalid binary tree."
            null
        else if pos is 'left'
          if @left.is_terminal()
            @left = null
          else
            console.log "Error deleting #{@left.data}, results in invalid binary tree."
            null
        else
          if this.is_terminal()
            @data = null
          else
            console.log "Error deleting #{@data}, results in invalid binary tree."
            null

      # Allows the user to index into the tree, following Preorder traversal:
      # ROOT, left, right
      index: (index) ->
        this.__access(index)

      # Determine how far away the node at position 'index' is from the root
      # of the binary tree.  This is used to determine how long the mutation
      # tree at a given point can be to maintain the maximum depth of the
      # tree during the point mutation genetic operation.
      depthAtPoint: (index, curDepth = 1) ->
        this.__access(index, false, curDepth)
      
      # Internal method used to abstract the index and depth at point member
      # functions.
      ###
      # WARNING:  INTERNAL METHOD.  DO NOT CALL
      ###
      __access: (index, value = true, curDepth = 1) ->
        if index is 0
          return if value is true then this else curDepth
        leftSize = if @left is null then 0 else @left.treeSize()
        rightSize = if @right is null then 0 else @right.treeSize()
        if index > leftSize + rightSize
          -1
        else if index > leftSize
          @right.__access(index - leftSize - 1, value, curDepth + 1)
        else
          @left.__access(index - 1, value, curDepth + 1)
      
      # Given a tree, replace it with a randomly-generated tree whose maximum 
      # depth is given by maxDepth. 
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      generate: (maxDepth = 10, curDepth = 1) ->
        if curDepth is maxDepth
          this.insertData(window.binaryTree.terminals[Math.floor(Math.random() * window.binaryTree.terminals.length)])
        else
          randomGene = Math.floor(Math.random() * (binaryTree.terminals.length + binaryTree.operators.length))
          if randomGene < binaryTree.terminals.length
            this.insertData(binaryTree.terminals[randomGene])
          else
            gene = binaryTree.operators[randomGene - binaryTree.terminals.length]
            this.insertData(gene)
            this.left = new binaryTree(this)
            this.left.generate(maxDepth, curDepth + 1)
            if gene.length isnt 1
              this.right = new binaryTree(this)
              this.right.generate(maxDepth, curDepth + 1)

      # Evaluate the Binary tree numerically for a given input value
      evaluate: (x) ->
        if @data is 'x'
          x
        else if typeof(@data) is 'number'
          @data
        else
          if @data.length is 1
            @data(this.left.evaluate(x))
          else
            @data(this.left.evaluate(x), this.right.evaluate(x))

      # Insert the binaryTree object 'tree' at the location of the binaryTree 
      # specified by index
      ###
      # WARNING:  MUTATES THE BINARY TREE 'THIS', DOES NOT MUTATE ARGUMENT TREE
      ###
      insertTree: (tree, index = 0) ->
        replacementPoint = this.index(index)
        if index is null
          console.log "Error inserting #{tree} at location specified.  Index does not exist in the tree."
          null
        else
          start = replacementPoint.parent
          if start isnt null
            if start.left isnt null and window.binaryTree.is_equal(replacementPoint, start.left)
              start.left = window.binaryTree.clone(tree)
            else
              if start.right isnt null and window.binaryTree.is_equal(replacementPoint, start.right)
                start.right = window.binaryTree.clone(tree)
            start.__updateParents()
          else
            this.data = tree.data
            this.right = binaryTree.clone(tree.right)
            this.left = binaryTree.clone(tree.left)
            this.parent = null
            this.__updateParents()



      # Updates binary tree element's parents to reflect the result of
      # an insertTree merger to parent.right or parent.left
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      ###
      # WARNING:  INTERNAL METHOD.  DO NOT CALL.
      ###
      __updateParents: ->
        if this.right isnt null
          this.right = window.binaryTree.clone(this.right, this)
          this.right.__updateParents()
        if this.left isnt null
          this.left = window.binaryTree.clone(this.left, this)
          this.left.__updateParents()

      # Given two parent trees, create two new child trees by crossover.
      # Both parent trees are given a randomly-selected crossover point.
      # The first child is the part of the first parent before its crossover
      # point, and the section of the second parent after its crossover point.
      # The second child is the part of the first parent after its crossover
      # point, and the part of the second parent before its crossover point.

      @crossover: (tree1, tree2) ->
        [tree1a, tree1b] = [window.binaryTree.clone(tree1), window.binaryTree.clone(tree1)]
        [tree2a, tree2b] = [window.binaryTree.clone(tree2), window.binaryTree.clone(tree2)]
        
        [crossoverPointOne, crossoverPointTwo] = \
        [Math.floor(Math.random() * tree1.treeSize()), Math.floor(Math.random() * tree2.treeSize())]
        
        [childOne, childTwo] = [window.binaryTree.clone(tree1a), window.binaryTree.clone(tree2a)]
        childOne.insertTree(childTwo.index(crossoverPointTwo), crossoverPointOne)
        childTwo.insertTree(tree1b.index(crossoverPointOne), crossoverPointTwo)
        return [childOne, childTwo]

    window.testTree = new binaryTree
    testTree.insertData((a, b) -> a * b)
    testTree.insertData(3, 'left')
    testTree.insertData(2, 'right')
    window.testTree2 = new binaryTree
    testTree2.insertData((a, b) -> a * b)
    testTree2.insertData('x', 'left')
    testTree2.insertData('x', 'right')
    window.result = window.binaryTree.crossover(testTree, testTree2)