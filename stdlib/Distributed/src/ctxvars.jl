abstract type AbstractDistributedContext end

struct NoDistributedContext <: AbstractDistributedContext end

const DISTRIBUTED_CONTEXT = Ref{AbstractDistributedContext}(NoDistributedContext())

get_distributed_context() = DISTRIBUTED_CONTEXT[]
function set_distributed_context(ctx::AbstractDistributedContext)
    DISTRIBUTED_CONTEXT[] = ctx
    nothing
end

function run_work_thunk_in_ctx(thunk::Function, print_error::Bool, ctxvars)
    invokelatest(with_context_vars, ()->run_work_thunk(thunk, print_error), get_distributed_context(), ctxvars)
end
function run_work_thunk_in_ctx(rv::RemoteValue, thunk, ctxvars)
    invokelatest(with_context_vars, ()->run_work_thunk(rv, thunk), get_distributed_context(), ctxvars)
end

get_context_vars() = get_context_vars(get_distributed_context())
get_context_vars(::NoDistributedContext) = nothing
with_context_vars(f::Function, ::NoDistributedContext, ctxvars) = f()
