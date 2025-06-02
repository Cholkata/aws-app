  resource "aws_eks_cluster" "testCluster" { 
    name     = "test-cluster"
    role_arn = "arn:aws:iam::179359595824:role/AmazonEKSAutoClusterRole"
    version = "1.33"

    vpc_config {
      subnet_ids = [aws_subnet.main.id, aws_subnet.main2.id]
    }

  
  }

  resource "aws_eks_node_group" "testNodeGroup" {
    cluster_name    = aws_eks_cluster.testCluster.name
    node_group_name = "test-node-group"
    node_role_arn   = "arn:aws:iam::179359595824:role/AmazonEKSAutoNodeRole"
    subnet_ids      = [aws_subnet.main2.id]

    scaling_config {
      desired_size = 2
      max_size     = 3
      min_size     = 1
    }
    instance_types = ["t3.medium"]
  }
