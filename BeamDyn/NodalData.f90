   SUBROUTINE NodalData(Nuuu,Nrrr,Nuu0,Nrr0,E10,hhp,Stif0,Jac,&
                        &node_elem,nnode,dof_node,&
                        &E1,RR0,kapa,Stif,cet)
 
   REAL(ReKi),INTENT(IN)::Nuuu(:),Nrrr(:),Nuu0(:),Nrr0(:)
   REAL(ReKi),INTENT(IN)::E10(:),hhp(:,:),Stif0(:,:),Jac
   INTEGER(IntKi),INTENT(IN)::node_elem,nnode,dof_node

   REAL(ReKi),INTENT(INOUT)::E1(:),RR0(:,:),kapa(:)
   REAL(ReKi),INTENT(INOUT)::Stif(:,:),cet

   REAL(ReKi)::cc0(3),ccc(3),cc(3),rrr(3),tempR(3,3),tempR6(6,6)
   REAL(ReKi)::Nuuu_temp(3),tempH(3,3),rrp(3),Nuuu_temp1(3)
   INTEGER(IntKi)::i,j,temp_id
 
   rrp = 0.0D0
   cc0 = 0.0D0
   ccc = 0.0D0
   cc  = 0.0D0
   rrr = 0.0D0
   tempR = 0.0D0
   tempR6 = 0.0D0
   Nuuu_temp = 0.0D0
   tempH = 0.0D0
   Nuuu_temp1 = 0.0D0
   DO i=1,node_elem
       temp_id = (i-1)*dof_node
       E1(1) = E1(1) + hhp(i,nnode)*Nuuu(temp_id+1)
       E1(2) = E1(2) + hhp(i,nnode)*Nuuu(temp_id+2)
       E1(3) = E1(3) + hhp(i,nnode)*Nuuu(temp_id+3)
          
       temp_id = (i-1)*3
       rrp(1) = rrp(1) + hhp(i,nnode)*Nrrr(temp_id+1)
       rrp(2) = rrp(2) + hhp(i,nnode)*Nrrr(temp_id+2)
       rrp(3) = rrp(3) + hhp(i,nnode)*Nrrr(temp_id+3) 
   ENDDO
   E1 = E1/Jac
   E1 = E1 + E10
   rrp = rrp / Jac

   temp_id = (nnode-1)*dof_node+3
   DO i=1,3
       cc0(i) = Nuu0(temp_id+i)
       ccc(i) = Nuuu(temp_id+i)
   ENDDO
   CALL CrvCompose(cc,ccc,cc0,0)
!   DO i=1,3
!       WRITE(*,*) "cc(i) = ", cc(i)
!   ENDDO
   CALL CrvMatrixR(cc,RR0)
   
!   DO i=1,3
!       WRITE(*,*)  RR0(i,1),RR0(i,2),RR0(i,3)
!       200 FORMAT(3ES20.10)
!   ENDDO
   tempR6 = 0.0d0
   DO i=1,3
       DO j=1,3
           tempR6(i,j) = RR0(i,j)
           tempR6(i+3,j+3) = RR0(i,j)
       ENDDO
   ENDDO

   Stif(1:6,1:6) = Stif0(1:6,1:6)
   cet = Stif(5,5) + Stif(6,6)
   Stif = MATMUL(tempR6,MATMUL(Stif,TRANSPOSE(tempR6)))

   temp_id = (nnode-1)*3
   DO i=1,3
       rrr(i) = Nrrr(temp_id+i)
   ENDDO
     
   temp_id = 3
   Nuuu_temp = 0.0D0
   DO i=1,3
       Nuuu_temp1(i) = Nuuu(temp_id+i)
   ENDDO
   tempH = 0.0D0
   CALL CrvmatrixH(rrr,tempH)
   cc = 0.0D0
   cc = MATMUL(tempH,rrp)
   tempR = 0.0D0
   CALL CrvMatrixR(Nuuu_temp1,tempR)
   kapa = MATMUL(tempR,cc)
      
   END SUBROUTINE NodalData
