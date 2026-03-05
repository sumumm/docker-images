import React, { useState, useEffect } from 'react';
import {
  ChakraProvider,
  Box,
  VStack,
  HStack,
  Input,
  Button,
  Text,
  Checkbox,
  Container,
  Heading,
  useToast
} from '@chakra-ui/react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

function App() {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState('');
  const toast = useToast();

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      const response = await axios.get(`${API_URL}/todos`);
      setTodos(response.data);
    } catch (error) {
      toast({
        title: '获取任务失败',
        status: 'error',
        duration: 2000,
      });
    }
  };

  const addTodo = async () => {
    if (!newTodo.trim()) return;
    try {
      await axios.post(`${API_URL}/todos`, { text: newTodo });
      setNewTodo('');
      fetchTodos();
      toast({
        title: '添加成功',
        status: 'success',
        duration: 2000,
      });
    } catch (error) {
      toast({
        title: '添加失败',
        status: 'error',
        duration: 2000,
      });
    }
  };

  const toggleTodo = async (id, completed) => {
    try {
      await axios.put(`${API_URL}/todos/${id}`, { completed: !completed });
      fetchTodos();
    } catch (error) {
      toast({
        title: '更新失败',
        status: 'error',
        duration: 2000,
      });
    }
  };

  const deleteTodo = async (id) => {
    try {
      await axios.delete(`${API_URL}/todos/${id}`);
      fetchTodos();
      toast({
        title: '删除成功',
        status: 'success',
        duration: 2000,
      });
    } catch (error) {
      toast({
        title: '删除失败',
        status: 'error',
        duration: 2000,
      });
    }
  };

  return (
    <ChakraProvider>
      <Container maxW="container.md" py={10}>
        <VStack spacing={8}>
          <Heading>Todo 应用</Heading>
          <HStack width="100%">
            <Input
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              placeholder="输入新的任务..."
              onKeyPress={(e) => e.key === 'Enter' && addTodo()}
            />
            <Button colorScheme="blue" onClick={addTodo}>
              添加
            </Button>
          </HStack>
          <VStack width="100%" align="stretch">
            {todos.map((todo) => (
              <Box
                key={todo._id}
                p={4}
                borderWidth={1}
                borderRadius="md"
                display="flex"
                justifyContent="space-between"
                alignItems="center"
              >
                <HStack>
                  <Checkbox
                    isChecked={todo.completed}
                    onChange={() => toggleTodo(todo._id, todo.completed)}
                  />
                  <Text
                    textDecoration={todo.completed ? 'line-through' : 'none'}
                  >
                    {todo.text}
                  </Text>
                </HStack>
                <Button
                  size="sm"
                  colorScheme="red"
                  onClick={() => deleteTodo(todo._id)}
                >
                  删除
                </Button>
              </Box>
            ))}
          </VStack>
        </VStack>
      </Container>
    </ChakraProvider>
  );
}

export default App; 