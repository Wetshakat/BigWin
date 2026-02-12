%lang cairo2

# --------------------------------------------
# Array Utilities Library
# --------------------------------------------
namespace ArrayUtils:

    # Append an element to a fixed-size array (emulated)
    # arr_ptr: pointer to the start of array in storage
    # arr_len_ptr: pointer to the current length of the array
    # max_len: maximum allowed length
    # element: value to append
    func append(arr_ptr: felt*, arr_len_ptr: felt*, max_len: felt, element: felt):
        let current_len = [arr_len_ptr]
        assert current_len < max_len, 'ARRAY_OVERFLOW'

        # Store the element at arr_ptr + current_len
        let target_ptr = arr_ptr + current_len
        [target_ptr] = element

        # Update length
        [arr_len_ptr] = current_len + 1
        return ()
    end

    # Get element at index
    func get(arr_ptr: felt*, arr_len: felt, index: felt) -> (element: felt):
        assert index < arr_len, 'INDEX_OUT_OF_BOUNDS'
        let element = [arr_ptr + index]
        return (element)
    end

    # Check if an element exists in the array
    func contains(arr_ptr: felt*, arr_len: felt, element: felt) -> (exists: felt):
        let mut i = 0
        while i < arr_len:
            if [arr_ptr + i] == element:
                return (exists=1)
            end
            let i = i + 1
        end
        return (exists=0)
    end

    # Remove element at index (shift remaining left)
    func remove_at(arr_ptr: felt*, arr_len_ptr: felt*, index: felt) -> (success: felt):
        let arr_len = [arr_len_ptr]
        assert index < arr_len, 'INDEX_OUT_OF_BOUNDS'

        # Shift elements
        let mut i = index
        while i < arr_len - 1:
            [arr_ptr + i] = [arr_ptr + i + 1]
            let i = i + 1
        end

        # Decrease length
        [arr_len_ptr] = arr_len - 1
        return (success=1)
    end

end
