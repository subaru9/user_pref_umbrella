# defmodule SingletonFailoverTest do
#   use ExUnit.Case
#
#   setup_all do
#     # Start the current node as a distributed node
#     :ok = LocalCluster.start()
#
#     # Start a cluster with 2 nodes
#     {:ok, cluster} = LocalCluster.start_link(2, prefix: "singleton_cluster")
#
#     # Retrieve the nodes in the cluster
#     {:ok, nodes} = LocalCluster.nodes(cluster)
#
#     # Start the `Singleton.Supervisor` on each node
#     Enum.each(nodes, fn node ->
#       :rpc.call(node, Application, :ensure_all_started, [:user_pref_web, :user_pref, :shared_utils])
#     end)
#
#     {:ok, %{cluster: cluster, nodes: nodes}}
#   end
#
#   # Define a simple GenServer
#   defmodule Foo do
#     use GenServer
#
#     def start_link(_args) do
#       GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
#     end
#
#     def init(state), do: {:ok, state}
#   end
#
#   test "singleton process failover", %{cluster: cluster, nodes: [node1, node2]} do
#     # Start the singleton process on node1
#     {:ok, _pid} =
#       :rpc.call(node1, Singleton, :start_child, [
#         SingletonTest.Supervisor,
#         Foo,
#         [],
#         Foo
#       ])
#
#     # Verify the process is running on node1
#     pid = :rpc.call(node1, :global, :whereis_name, [Foo])
#     assert is_pid(pid) === true
#     assert node(pid) === node1
#
#     # Stop node1 to simulate failure
#     {:ok, _} = LocalCluster.stop(cluster, node1)
#     :timer.sleep(500) # Allow time for failover
#
#     # Verify the process is restarted on node2
#     pid_after_failover = :rpc.call(node2, :global, :whereis_name, [Foo])
#     assert is_pid(pid_after_failover) === true
#     assert node(pid_after_failover) === node2
#
#     # Ensure the process is functional
#     assert :rpc.call(node2, GenServer, :call, [{:global, Foo}, :get_state]) === %{}
#   end
# end
